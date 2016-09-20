answers['foreman_proxy::plugin::dns::infoblox'] ||= false
scenario[:mapping][:'foreman_proxy::plugin::dns::infoblox'] ||= {:dir_name => 'foreman_proxy', :manifest_name => 'plugin/dns/infoblox', :params_name => 'plugin/dns/infoblox/params'}

answers['foreman_proxy::plugin::dhcp::infoblox'] ||= false
scenario[:mapping][:'foreman_proxy::plugin::dhcp::infoblox'] ||= {:dir_name => 'foreman_proxy', :manifest_name => 'plugin/dhcp/infoblox', :params_name => 'plugin/dhcp/infoblox/params'}
