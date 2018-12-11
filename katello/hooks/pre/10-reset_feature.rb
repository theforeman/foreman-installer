# See bottom of the script for the command that kicks off the script

def reset
  if foreman_installed?

    stop_services
    reset_database
    reset_candlepin
    reset_pulp

  else
    Kafo::KafoConfigure.logger.warn 'Katello not installed yet, can not drop database!'
  end
end

def foreman_installed?
  `which foreman-rake > /dev/null 2>&1`
  $?.success?
end

def stop_services
  Kafo::KafoConfigure.logger.info 'Stopping services'
  Kafo::Helpers.execute('katello-service stop --exclude postgresql')
end

def load_foreman_config
  db_config = {}
  db_config[:host] = param_value('foreman', 'db_host') || 'localhost'
  db_config[:port] = param_value('foreman', 'db_port')
  db_config[:database] = param_value('foreman', 'db_database') || 'foreman'
  db_config[:username] = param_value('foreman', 'db_username')
  db_config[:password] = param_value('foreman', 'db_password')
  db_config
end

def reset_database
  Kafo::KafoConfigure.logger.info 'Dropping database!'

  config = load_foreman_config
  if remote_host?(config[:host])
    empty_database!(config)
  else
    Kafo::Helpers.execute('DISABLE_DATABASE_ENVIRONMENT_CHECK=1 foreman-rake db:drop 2>&1')
  end
end

def load_candlepin_config
  db_config = {}
  db_config[:host] = param_value('katello', 'candlepin_db_host') || 'localhost'
  db_config[:port] = param_value('katello', 'candlepin_db_port')
  db_config[:database] = param_value('katello', 'candlepin_db_name') || 'candlepin'
  db_config[:username] = param_value('katello', 'candlepin_db_user')
  db_config[:password] = param_value('katello', 'candlepin_db_password')
  db_config
end

def empty_candlepin_database
  config = load_candlepin_config
  if remote_host?(config[:host])
    empty_database!(config)
  else
    Kafo::Helpers.execute("sudo -u postgres dropdb #{config[:database]}")
  end
end

def reset_candlepin
  Kafo::KafoConfigure.logger.info 'Dropping Candlepin database!'
  commands = [
    'rm -f /var/lib/candlepin/cpdb_done',
    'rm -f /var/lib/candlepin/cpinit_done',
    'systemctl stop tomcat'
  ]
  Kafo::Helpers.execute(commands)
  empty_candlepin_database
end

def empty_mongo
  mongo_config = load_mongo_config
  if remote_host?(mongo_config[:host])
    empty_remote_mongo(mongo_config)
  else
    Kafo::Helpers.execute(
      [
        'systemctl start rh-mongodb34-mongod',
        "mongo #{mongo_config[:database]} --eval 'db.dropDatabase();'"
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
  Kafo::Helpers.execute(cmd)
end

def reset_pulp
  Kafo::KafoConfigure.logger.info 'Dropping Pulp database!'

  Kafo::Helpers.execute(
    [
      'rm -f /var/lib/pulp/init.flag',
      'systemctl stop httpd pulp_workers'
    ]
  )
  empty_mongo
  Kafo::Helpers.execute(
    'rm -rf /var/lib/pulp/{distributions,published,repos}/*'
  )
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
  system(pg_sql_statement(config, delete_statements)) if delete_statements
end

if app_value(:reset) && !app_value(:noop)
  response = ask('Are you sure you want to continue? This will drop the databases, reset all configurations that you have made and bring the server back to a fresh install. [y/n]')
  if response.downcase != 'y'
    $stderr.puts '** cancelled **'
    kafo.class.exit(1)
  else
    reset
  end
end
