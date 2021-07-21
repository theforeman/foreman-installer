migrate_module('foreman_proxy::plugin::remote_execution::ssh'] do |mod|
  if mod['ssh_identity_dir'] == '/usr/share/foreman-proxy/.ssh' || mod['ssh_identity_dir'].nil?
    mod['ssh_identity_dir'] = '/var/lib/foreman-proxy/ssh'
  end
end
