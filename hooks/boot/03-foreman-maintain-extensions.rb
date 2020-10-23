module ForemanMaintainHookContextExtension
  def foreman_maintain(command)
    command = "foreman-maintain #{command}"
    execute(command, false, true)
  end

  def foreman_maintain!(command)
    command = "foreman-maintain #{command}"
    execute!(command, false, true)
  end
end

Kafo::HookContext.send(:include, ForemanMaintainHookContextExtension)
