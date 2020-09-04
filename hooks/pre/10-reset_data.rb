# See bottom of the script for the command that kicks off the script
require 'English'
require 'fileutils'

def reset
  stop_services
  start_services(['postgresql']) if local_postgresql?
  empty_db_in_postgresql('foreman') if foreman_server?
  reset_candlepin if candlepin_enabled?
  reset_pulp if pulp_enabled?
  reset_pulpcore if pulpcore_enabled?
end

def load_db_config(db)
  case db
  when 'foreman'
    module_name = 'foreman'
    user_param = 'username'
    db_param = 'database'
    param_prefix = 'db_'
  when 'candlepin'
    module_name = 'katello'
    user_param = 'user'
    db_param = 'name'
    param_prefix = 'candlepin_db_'
  when 'pulpcore'
    module_name = 'foreman_proxy_content'
    user_param = 'user'
    db_param = 'db_name'
    param_prefix = 'pulpcore_postgresql_'
  else
    raise "installer module unknown for db: #{db}"
  end

  {
    host: param_value(module_name, "#{param_prefix}host") || 'localhost',
    port: param_value(module_name, "#{param_prefix}port") || 5432,
    database: param_value(module_name, "#{param_prefix}#{db_param}") || db,
    username: param_value(module_name, "#{param_prefix}#{user_param}"),
    password: param_value(module_name, "#{param_prefix}password"),
  }
end

def empty_db_in_postgresql(db)
  logger.info "Dropping #{db} database!"

  config = load_db_config(db)
  if remote_host?(config[:host])
    empty_database!(config)
  else
    execute("sudo -u postgres dropdb #{config[:database]}")
  end
end

def reset_candlepin
  execute('rm -f /var/lib/candlepin/.puppet-candlepin-cpdb*')
  empty_db_in_postgresql('candlepin')
end

def empty_mongo(config)
  if config[:ssl]
    ssl = '--ssl'
    if config[:ca_path]
      ca_cert = "--sslCAFile #{config[:ca_path]}"
      client_cert = "--sslPEMKeyFile #{config[:ssl_certfile]}" if config[:ssl_certfile]
    end
  end
  username = "-u #{config[:username]}" if config[:username]
  password = "-p #{config[:password]}" if config[:password]
  host = "--host #{config[:host]} --port #{config[:port]}"
  cmd = "mongo #{config[:database]} #{username} #{password} #{host} #{ssl} #{ca_cert} #{client_cert} --eval 'db.dropDatabase();'"
  execute(cmd)
end

def reset_pulp
  execute('rm -f /var/lib/pulp/init.flag')

  mongo_config = load_mongo_config
  start_services(['rh-mongodb34-mongod']) unless remote_host?(mongo_config[:host])
  logger.info 'Dropping Pulp database!'
  empty_mongo(mongo_config)

  logger.info 'Clearing Pulp content from disk.'
  execute('rm -rf /var/lib/pulp/{distributions,published,repos,content}/*')
end

def pg_command_base(config, command, args)
  "PGPASSWORD='#{config[:password]}' #{command} -U #{config[:username]} -h #{config[:host]} -p #{config[:port]} #{args}"
end

def pg_sql_statement(config, statement)
  pg_command_base(config, 'psql', "-d #{config[:database]} -t -c \"" + statement + '"')
end

# WARNING: deletes all the data from a database. No warnings. No confirmations.
def empty_database!(config)
  generate_delete_statements = pg_sql_statement(config, %q(
        select string_agg('drop table if exists \"' || tablename || '\" cascade;', '')
        from pg_tables
        where schemaname = 'public';
      ))
  delete_statements = `#{generate_delete_statements}`
  execute(pg_sql_statement(config, delete_statements)) if delete_statements
end

def clear_pulpcore_content(content_dir)
  if File.directory?(content_dir)
    logging.debug "Removing Pulpcore content from '#{content_dir}'"
    FileUtils.rm_rf(content_dir)
    logger.info "Pulpcore content successfully removed from '#{content_dir}'"
  else
    logger.warn "Pulpcore content directory not present at '#{content_dir}'"
  end
end

def reset_pulpcore
  empty_db_in_postgresql('pulpcore')
  clear_pulpcore_content('/var/lib/pulp/docroot')
end

reset if app_value(:reset_data) && !app_value(:noop)
