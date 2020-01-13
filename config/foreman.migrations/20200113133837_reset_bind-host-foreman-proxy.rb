if answers['foreman_proxy'].is_a?(Hash) &&
    answers['foreman_proxy']['bind_host'].is_a?(Array) &&
    answers['foreman_proxy']['bind_host'].include?('::') &&
    facts[:os][:release][:major] == '7' &&
    facts[:os][:family] == 'RedHat'
  answers['foreman_proxy']['bind_host'].delete
end
