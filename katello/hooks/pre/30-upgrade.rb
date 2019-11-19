require 'fileutils'

STEP_DIRECTORY = '/etc/foreman-installer/applied_hooks/pre/'
SSL_BUILD_DIR = param('certs', 'ssl_build_dir').value

def stop_services
  Kafo::Helpers.execute('foreman-maintain service stop')
end

def start_postgresql
  Kafo::Helpers.execute('systemctl start postgresql')
end

def migrate_candlepin
  db_host = param('katello', 'candlepin_db_host').value
  db_port = param('katello', 'candlepin_db_port').value
  db_name = param('katello', 'candlepin_db_name').value
  db_user = param('katello', 'candlepin_db_user').value
  db_password = param('katello', 'candlepin_db_password').value
  db_ssl = param('katello', 'candlepin_db_ssl').value
  db_ssl_verify = param('katello', 'candlepin_db_ssl_verify').value
  db_uri = "//#{db_host}" + (db_port.nil? ? '' : ":#{db_port}") + "/#{db_name}"
  if db_ssl
    db_uri += "?ssl=true"
    db_uri += "&sslfactory=org.postgresql.ssl.NonValidatingFactory" unless db_ssl_verify
  end
  Kafo::Helpers.execute("/usr/share/candlepin/cpdb --update --database '#{db_uri}' --user '#{db_user}' --password '#{db_password}'")
end

def migrate_pulp
  # Start mongo
  Kafo::Helpers.execute('systemctl start rh-mongodb34-mongod')
  Kafo::Helpers.execute('su - apache -s /bin/bash -c pulp-manage-db')
end

def migrate_foreman
  Kafo::Helpers.execute('foreman-rake db:migrate')
end

def postgresql_10_upgrade
  stop_services
  Kafo::Helpers.execute('yum -y install rh-postgresql10-postgresql-server')
  Kafo::Helpers.execute('scl enable rh-postgresql10 -- postgresql-setup --upgrade')
  Kafo::Helpers.execute('yum -y remove postgresql postgresql-server')
  Kafo::Helpers.execute('rm -f /etc/systemd/system/postgresql.service')
  Kafo::Helpers.execute('yum -y install rh-postgresql10-syspaths')
end

def upgrade_step(step, options = {})
  noop = app_value(:noop) ? ' (noop)' : ''
  long_running = options[:long_running] ? ' (this may take a while) ' : ''
  run_always = options.fetch(:run_always, false)

  if run_always || app_value(:force_upgrade_steps) || !step_ran?(step)
    Kafo::Helpers.log_and_say :info, "Upgrade Step: #{step}#{long_running}#{noop}..."
    unless app_value(:noop)
      status = send(step)
      Kafo::Helpers.fail_and_exit "Upgrade step #{step} failed. Check logs for more information." unless status
      touch_step(step)
    end
  end
end

def touch_step(step)
  FileUtils.mkpath(STEP_DIRECTORY) unless Dir.exists?(STEP_DIRECTORY)
  FileUtils.touch(step_path(step))
end

def step_ran?(step)
  File.exists?(step_path(step))
end

def step_path(step)
  File.join(STEP_DIRECTORY, step.to_s)
end

if app_value(:upgrade)
  Kafo::Helpers.log_and_say :info, 'Upgrading, to monitor the progress on all related services, please do:'
  Kafo::Helpers.log_and_say :info, '  foreman-tail | tee upgrade-$(date +%Y-%m-%d-%H%M).log'
  sleep 3

  katello = module_enabled?('katello')
  foreman_proxy_content = param('foreman_proxy_plugin_pulp', 'pulpnode_enabled').value

  upgrade_step :stop_services, :run_always => true

  if local_postgresql?
    upgrade_step :start_postgresql, :run_always => true
  end

  if katello || foreman_proxy_content
    upgrade_step :migrate_pulp, :run_always => true
  end

  if katello
    upgrade_step :migrate_candlepin, :run_always => true
    upgrade_step :migrate_foreman, :run_always => true
  end

  if local_postgresql? && facts[:os][:release][:major] == '7'
    upgrade_step :postgresql_10_upgrade
  end

  Kafo::Helpers.log_and_say :info, 'Upgrade Step: Running installer...'
end
