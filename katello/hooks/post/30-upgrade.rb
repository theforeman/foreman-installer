require 'fileutils'

def db_seed
  status = execute('foreman-rake db:seed')
  fail_and_exit "Upgrade failed while seeding the DB" unless status
end

def upgrade_tasks
  status = execute('foreman-rake upgrade:run')
  fail_and_exit "Application Upgrade Failed" unless status
end

if app_value(:upgrade)
  if [0, 2].include?(@kafo.exit_code)
    if module_enabled?('foreman')
      db_seed
      upgrade_tasks
    end

    log_and_say :info, 'Upgrade completed!'
  else
    log_and_say :error, 'Upgrade failed during the installation phase. Fix the error and re-run the upgrade.'
  end
end
