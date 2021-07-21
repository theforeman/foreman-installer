migrate_module('foreman') do |mod|
  ['authentication', 'locations_enabled', 'organizations_enabled', 'repo'].each do |parameter|
    mod.unset_answer(parameter)
  end
end

migrate_module('foreman_proxy') do |mod|
  mod.unset_answer('repo')
  mod.unset_answer('dhcp_gateway') if mod['dhcp_gateway'] == '192.168.100.1'
end
