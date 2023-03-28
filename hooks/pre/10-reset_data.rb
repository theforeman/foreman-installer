# See bottom of the script for the command that kicks off the script
require 'English'
require 'fileutils'

def reset
  stop_services
  start_services(['postgresql']) if local_postgresql?
  empty_db_in_postgresql('foreman') if foreman_server?
  reset_candlepin if candlepin_enabled?
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
  logger.notice "Dropping #{db} database!"

  config = load_db_config(db)
  if remote_host?(config[:host])
    empty_database!(config)
  else
    execute!("runuser -l postgres -c 'dropdb #{config[:database]}'", false, true)
  end
end

def reset_candlepin
  execute!('rm -f /var/lib/candlepin/.puppet-candlepin-*', false, true)
  empty_db_in_postgresql('candlepin')
end

def pg_command_base(config, command, args)
  "PGPASSWORD='#{config[:password]}' #{command} -U #{config[:username]} -h #{config[:host]} -p #{config[:port]} #{args}"
end

def pg_sql_statement(config, statement)
  pg_command_base(config, 'psql', "-d #{config[:database]} -t -c \"" + statement + '"')
end

# WARNING: deletes all the data owned by the user. No warnings. No confirmations.
def empty_database!(config)
  delete_statement = 'DROP OWNED BY CURRENT_USER CASCADE;'
  execute!(pg_sql_statement(config, delete_statement), false, true)
end

def clear_pulpcore_content(content_dir)
  if File.directory?(content_dir)
    logger.notice "Removing Pulpcore content from '#{content_dir}'"
    FileUtils.rm_rf(content_dir)
    logger.notice "Pulpcore content successfully removed from '#{content_dir}'"
  else
    logger.warn "Pulpcore content directory not present at '#{content_dir}'"
  end
end

def reset_pulpcore
  empty_db_in_postgresql('pulpcore')
  clear_pulpcore_content('/var/lib/pulp/docroot')
end

reset if app_value(:reset_data) && !app_value(:noop)
