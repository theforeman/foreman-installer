module ForemanMaintainHookContextExtension
  def foreman_maintain(command)
    command = "foreman-maintain #{command}"
    execute_command(command, false, true)
  end

  def foreman_maintain!(command)
    status = foreman_maintain(command)
    exit 1 unless status
    status
  end
end

Kafo::HookContext.send(:include, ForemanMaintainHookContextExtension)
