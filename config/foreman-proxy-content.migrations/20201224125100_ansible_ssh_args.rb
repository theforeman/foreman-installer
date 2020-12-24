# migrate the default
if answers['foreman_proxy::plugin::ansible'].is_a?(Hash) && answers['foreman_proxy::plugin::ansible']['ssh_args'] == '-o ProxyCommand=none'
  answers['foreman_proxy::plugin::ansible']['ssh_args'] = '-o ProxyCommand=none -C -o ControlMaster=auto -o ControlPersist=60s'
end
