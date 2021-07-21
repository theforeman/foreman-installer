# Redetermine the value of API whitelists, as it changed
# in puppet-puppet f9b4e87cd855d7d5d0bbf3a1831b5daf22cdb413
migrate_module('puppet') do |mod|
  mod.delete('server_admin_api_whitelist')
  mod.delete('server_ca_client_whitelist')
end
