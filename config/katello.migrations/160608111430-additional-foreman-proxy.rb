def move(name, new_name=nil, default=nil)
  return unless answers['capsule'].key?(name)
  answers['foreman_proxy'][(new_name || name)] = answers['capsule'].delete(name) { |k| default }
end

# migrate addtional fields from the legacy capsule configuration to foreman_proxy
if answers['capsule'].is_a? Hash
  move('bmc', 'bmc')
  move('bmc_default_provider', 'bmc_default_provider')
  move('dhcp', 'dhcp')
  move('dhcp_listen_on', 'dhcp_listen_on')
  move('dhcp_option_domain', 'dhcp_option_domain')
  move('dhcp_interface', 'dhcp_interface')
  move('dhcp_gateway', 'dhcp_gateway')
  move('dhcp_managed', 'dhcp_managed')
  move('dhcp_range', 'dhcp_range')
  move('dhcp_nameservers', 'dhcp_nameservers')
  move('dhcp_vendor', 'dhcp_vendor')
  move('dhcp_config', 'dhcp_config')
  move('dhcp_leases', 'dhcp_leases')
  move('dhcp_key_name', 'dhcp_key_name')
  move('dhcp_key_secret', 'dhcp_key_secret')
  move('dns', 'dns')
  move('dns_managed', 'dns_managed')
  move('dns_provider', 'dns_provider')
  move('dns_zone', 'dns_zone')
  move('dns_reverse', 'dns_reverse')
  move('dns_interface', 'dns_interface')
  move('dns_server', 'dns_server')
  move('dns_ttl', 'dns_ttl')
  move('dns_tsig_keytab', 'dns_tsig_keytab')
  move('dns_tsig_principal', 'dns_tsig_principal')
  move('dns_forwarders', 'dns_forwarders')
  move('virsh_network', 'virsh_network')
  move('realm', 'realm')
  move('realm_provider', 'realm_provider')
  move('realm_keytab', 'realm_keytab')
  move('realm_principal', 'realm_principal')
  move('freeipa_remove_dns', 'freeipa_remove_dns')
  move('register_in_foreman', 'register_in_foreman')

  if answers['certs'].is_a?(Hash) && !answers['certs']['node_fqdn'].nil?
    answers['foreman_proxy']['registered_proxy_url'] = "https://#{answers['certs']['node_fqdn']}:#{answers['foreman_proxy']['ssl_port']}"
  end
end
