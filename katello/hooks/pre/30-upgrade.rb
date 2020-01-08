require 'fileutils'

STEP_DIRECTORY = '/etc/foreman-installer/applied_hooks/pre/'.freeze

# puppet-candlepin users this file to know whether it needs to run cpdb --update
CANDLEPIN_MIGRATION_MARKER_FILE = '/var/lib/candlepin/cpdb_update_done'.freeze
# puppet-pulp uses this file to know whether it needs to run pulp-manage-db
PULP2_MIGRATION_MARKER_FILE = '/var/lib/pulp/init.flag'.freeze

def stop_services
  execute('foreman-maintain service stop')
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

  log_and_say :info, 'Upgrade Step: Running installer...'
end
