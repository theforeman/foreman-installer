ansible_module = answers['foreman_proxy::plugin::ansible']

if ansible_module.is_a?(Hash) && ansible_module['ssh_args'] == '-o ProxyCommand=none -C -o ControlMaster=auto -o ControlPersist=60s'
  ansible_module['ssh_args'] += ' -o ControlPersist=60s -o ServerAliveInterval=15 -o ServerAliveCountMax=3'
end
