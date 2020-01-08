require 'fileutils'

module UpgradeHookContextExtension
  STEP_DIRECTORY = '/etc/foreman-installer/applied_hooks/pre/'

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
    FileUtils.mkpath(STEP_DIRECTORY) unless Dir.exists?(STEP_DIRECTORY)
    FileUtils.touch(step_path(step))
  end

  def step_ran?(step)
    File.exists?(step_path(step))
  end

  def step_path(step)
    File.join(STEP_DIRECTORY, step.to_s)
  end
end

Kafo::HookContext.send(:include, UpgradeHookContextExtension)
