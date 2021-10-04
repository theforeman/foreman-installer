CLEAR = {
  'foreman' => [
    'authentication',
    'locations_enabled',
    'organizations_enabled',
    'repo',
  ],
  'foreman_proxy' => [
    'repo',
  ],
}.freeze

CLEAR.each do |mod, parameters|
  mod_answers = answers[mod]
  next unless mod_answers.is_a?(Hash)

  parameters.each do |parameter|
    mod_answers[parameter] = nil if mod_answers[parameter]
  end
end

if (mod_answers = answers['foreman_proxy']) && mod_answers.is_a?(Hash)
  mod_answers['dhcp_gateway'] = nil if mod_answers['dhcp_gateway'] == '192.168.100.1'
end
