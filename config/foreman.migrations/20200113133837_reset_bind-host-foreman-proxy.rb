migrate_module('foreman_proxy') do |mod|
  if mod['bind_host'].is_a?(Array) && mod['bind_host'].include?('::') && facts[:os][:release][:major] == '7' && facts[:os][:family] == 'RedHat'
    mod.unset_answer('bind_host')
  end
end
