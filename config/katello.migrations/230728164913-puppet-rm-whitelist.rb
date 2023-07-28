puppet = answers['puppet']
if puppet.is_a?(Hash)
  puppet['server_ca_client_allowlist'] = puppet.delete('server_ca_client_whitelist') if puppet.key?('server_ca_client_whitelist')
  puppet['server_admin_api_allowlist'] = puppet.delete('server_admin_api_whitelist') if puppet.key?('server_admin_api_whitelist')
  puppet['server_jolokia_metrics_allowlist'] = puppet.delete('server_jolokia_metrics_whitelist') if puppet.key?('server_jolokia_metrics_whitelist')
end
