if facts[:os][:family] == 'RedHat' && facts[:os][:release][:major] == '8'
  if answers['foreman_proxy::plugin::pulp'].is_a?(Hash)
    answers['foreman_proxy::plugin::pulp']['enabled'] = false
    answers['foreman_proxy::plugin::pulp']['pulpnode_enabled'] = false
  elsif answers['foreman_proxy::plugin::pulp'] == true
    answers['foreman_proxy::plugin::pulp'] = { 'enabled' => false, 'pulpnode_enabled' => false }
  end
end
