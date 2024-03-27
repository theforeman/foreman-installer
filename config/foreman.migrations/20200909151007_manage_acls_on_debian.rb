if answers['foreman_proxy'].is_a?(Hash) && facts[:os][:family] == 'Debian' && answers['foreman_proxy'].key?('dhcp_manage_acls')
  answers['foreman_proxy']['dhcp_manage_acls'] ||= true
end
