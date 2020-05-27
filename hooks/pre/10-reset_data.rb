# See bottom of the script for the command that kicks off the script
require 'English'

def reset
  stop_services
  start_services(['postgresql']) if local_postgresql?
  empty_db_in_postgresql('foreman') if foreman_server?
  reset_candlepin if module_enabled?('katello')
  reset_pulp if pulp_enabled?
  empty_db_in_postgresql('pulpcore') if pulpcore_enabled?
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
  execute('rm -f /var/lib/candlepin/{cpdb_done,cpinit_done}')
  empty_db_in_postgresql(db)
end

def empty_mongo
  logger.info "Dropping Pulp database!"

  mongo_config = load_mongo_config
  if remote_host?(mongo_config[:host])
    empty_remote_mongo(mongo_config)
  else
    execute(
      [
        'systemctl start rh-mongodb34-mongod',
        "mongo #{mongo_config[:database]} --eval 'db.dropDatabase();'",
      ]
    )
  end
end

def load_mongo_config
  config = {}
  seeds = param_value('katello', 'pulp_db_seeds')
  seed = seeds.split(',').first
  host, port = seed.split(':') if seed
  config[:host] = host || 'localhost'
  config[:port] = port || '27017'
  config[:database] = param_value('katello', 'pulp_db_name') || 'pulp_database'
  config[:username] = param_value('katello', 'pulp_db_username')
  config[:password] = param_value('katello', 'pulp_db_password')
  config[:ssl] = param_value('katello', 'pulp_db_ssl') || false
  config[:ca_path] = param_value('katello', 'pulp_db_ca_path')
  config[:ssl_certfile] = param_value('katello', 'pulp_db_ssl_certfile')
  config
end

def empty_remote_mongo(config)
  if config[:ssl]
    ssl = "--ssl"
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
  empty_mongo
  execute('rm -rf /var/lib/pulp/{distributions,published,repos}/*')
end

def remote_host?(hostname)
  !['localhost', '127.0.0.1', `hostname`.strip].include?(hostname)
end

def pg_command_base(config, command, args)
  port = "-p #{config[:port]}" if config[:port]
  "PGPASSWORD='#{config[:password]}' #{command} -U #{config[:username]} -h #{config[:host]} #{port} #{args}"
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

if app_value(:reset_data) && !app_value(:noop)
  response = ask('Are you sure you want to continue? This will drop the databases, reset all configurations that you have made and bring all application data back to a fresh install. [y/n]')
  if response.downcase != 'y'
    $stderr.puts '** cancelled **'
    exit(1)
  else
    reset
  end
end
