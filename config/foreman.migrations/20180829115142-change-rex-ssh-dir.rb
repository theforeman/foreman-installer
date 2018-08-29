plugin_conf = answers['foreman_proxy::plugin::remote_execution::ssh']
if plugin_conf
  if plugin_conf.is_a?(Hash) && plugin_conf['ssh_identity_dir'] == '/usr/share/foreman-proxy/.ssh'
    answers['foreman_proxy::plugin::remote_execution::ssh']['ssh_identity_dir'] = '/var/lib/foreman-proxy/ssh'
  elsif !plugin_conf.is_a?(Hash)
    answers['foreman_proxy::plugin::remote_execution::ssh'] = { 'ssh_identity_dir' => '/var/lib/foreman-proxy/ssh' }
  end
end
