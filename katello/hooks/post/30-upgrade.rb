require 'fileutils'

def upgrade_tasks
  status = Kafo::Helpers.execute('foreman-rake upgrade:run')
  fail_and_exit "Application Upgrade Failed" unless status
end

def fail_and_exit(message)
  Kafo::Helpers.log_and_say :error, message
  kafo.class.exit 1
end

if app_value(:upgrade)
  if [0, 2].include?(@kafo.exit_code)
    upgrade_tasks if Kafo::Helpers.module_enabled?(@kafo, 'foreman')
    Kafo::Helpers.log_and_say :info, 'Upgrade completed!'
  else
    Kafo::Helpers.log_and_say :error, 'Upgrade failed during the installation phase. Fix the error and re-run the upgrade.'
  end
end
