migrate_module('foreman_proxy') do |mod|
  if mod['bind_host'].is_a?(String)
    mod['bind_host'] = [mod['bind_host']]
  end
end
