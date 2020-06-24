module ForemanMaintainHookContextExtension
  def package_lock_feature?
    foreman_maintain('packages -h')
  end

  def packages_locked?
    foreman_maintain('packages is-locked --assumeyes')
  end

  def lock_packages
    foreman_maintain('packages lock --assumeyes', true)
  end

  def unlock_packages
    foreman_maintain('packages unlock --assumeyes', true)
  end

  def start_services(services)
    foreman_maintain("service start --only=#{services.join(',')}", true)
  end

  def stop_services(services = nil)
    command = "service stop"
    command = "service stop --only=#{services.join(',')}" if services

    foreman_maintain(command, true)
  end

  def foreman_maintain(command, exit_on_fail = false)
    command = "foreman-maintain #{command}"
    status = execute_command(command, false, true)

    exit 1 if exit_on_fail && !status
    status
  end
end

Kafo::HookContext.send(:include, ForemanMaintainHookContextExtension)
