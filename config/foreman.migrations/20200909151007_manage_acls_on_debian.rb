migrate_module('foreman_proxy') do |mod|
  if facts[:os][:family] == 'Debian'
    mod['dhcp_manage_acls'] ||= true if mod.key?('dhcp_manage_acls')
  end
end
