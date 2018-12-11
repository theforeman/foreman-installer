if answers['foreman_proxy'].is_a?(Hash)
  answers['foreman_proxy']['manage_puppet_group'] = false
elsif answers['foreman_proxy'] == true
  answers['foreman_proxy'] = {'manage_puppet_group' => false}
end
