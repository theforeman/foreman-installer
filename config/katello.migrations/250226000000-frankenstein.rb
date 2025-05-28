answers.delete_if do |key, _value|
  ['foreman', 'foreman_proxy_content', 'apache::mod::status'].include?(key) || key.start_with?('foreman::')
end
