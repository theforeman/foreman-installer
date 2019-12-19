require 'fileutils'

STEP_DIRECTORY = '/etc/foreman-installer/applied_hooks/pre/'.freeze

# puppet-candlepin users this file to know whether it needs to run cpdb --update
CANDLEPIN_MIGRATION_MARKER_FILE = '/var/lib/candlepin/cpdb_update_done'.freeze
# puppet-pulp uses this file to know whether it needs to run pulp-manage-db
PULP2_MIGRATION_MARKER_FILE = '/var/lib/pulp/init.flag'.freeze

def stop_services
  execute('foreman-maintain service stop')
end

def start_postgresql
  execute('systemctl start postgresql')
end

def postgresql_10_upgrade
  start_postgresql
  (_name, _owner, _enconding, collate, ctype, _privileges) = `runuser postgres -c 'psql -lt | grep -E "^\s+postgres"'`.chomp.split('|').map(&:strip)
  stop_services
  ensure_package('rh-postgresql10-postgresql-server', 'installed')
  execute(%(scl enable rh-postgresql10 "PGSETUP_INITDB_OPTIONS='--lc-collate=#{collate} --lc-ctype=#{ctype} --locale=#{collate}' postgresql-setup --upgrade"))
  ensure_package('postgresql-server', 'absent')
  ensure_package('postgresql', 'absent')
  execute('rm -f /etc/systemd/system/postgresql.service')
  ensure_package('rh-postgresql10-syspaths', 'installed')
end

def upgrade_step(step, options = {})
  noop = app_value(:noop) ? ' (noop)' : ''
  long_running = options[:long_running] ? ' (this may take a while) ' : ''
  run_always = options.fetch(:run_always, false)

  if run_always || app_value(:force_upgrade_steps) || !step_ran?(step)
    log_and_say :info, "Upgrade Step: #{step}#{long_running}#{noop}..."
    unless app_value(:noop)
      send(step)
      touch_step(step)
    end
  end
end

def touch_step(step)
  FileUtils.mkpath(STEP_DIRECTORY) unless Dir.exist?(STEP_DIRECTORY)
  FileUtils.touch(step_path(step))
end

def step_ran?(step)
  File.exist?(step_path(step))
end

def step_path(step)
  File.join(STEP_DIRECTORY, step.to_s)
end

if app_value(:upgrade)
  log_and_say :info, 'Upgrading, to monitor the progress on all related services, please do:'
  log_and_say :info, '  foreman-tail | tee upgrade-$(date +%Y-%m-%d-%H%M).log'
  sleep 3

  upgrade_step :stop_services, :run_always => true

  if File.exist?(PULP2_MIGRATION_MARKER_FILE)
    File.unlink(PULP2_MIGRATION_MARKER_FILE)
  end

  if File.exist?(CANDLEPIN_MIGRATION_MARKER_FILE)
    File.unlink(CANDLEPIN_MIGRATION_MARKER_FILE)
  end

  if local_postgresql? && facts[:os][:release][:major] == '7'
    upgrade_step :postgresql_10_upgrade
  end

  log_and_say :info, 'Upgrade Step: Running installer...'
end
