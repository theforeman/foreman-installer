# migrate the default
migrate_module('foreman_proxy::plugin::ansible') do |mod|
  if mod['ssh_args'] == '-o ProxyCommand=none'
    mod['ssh_args'] = '-o ProxyCommand=none -C -o ControlMaster=auto -o ControlPersist=60s'
  end
end
