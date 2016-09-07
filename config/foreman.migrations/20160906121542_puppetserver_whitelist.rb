# Redetermine the value of API whitelists, as it changed
# in puppet-puppet XXX
if answers['puppet']
  answers['puppet'].delete('server_admin_api_whitelist')
  answers['puppet'].delete('server_ca_client_whitelist')
end
