# Redetermine the value of API whitelists, as it changed
# in puppet-puppet f9b4e87cd855d7d5d0bbf3a1831b5daf22cdb413
if answers['puppet'].is_a?(Hash)
  answers['puppet'].delete('server_admin_api_whitelist')
  answers['puppet'].delete('server_ca_client_whitelist')
end
