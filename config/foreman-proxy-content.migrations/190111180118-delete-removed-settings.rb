DELETED = {
  'foreman' => [
    'custom_repo',
    'dynflow_in_core',
    'email_conf',
    'email_config_method',
    'email_source',
    'puppet_home',
    'puppet_ssldir',
  ],
  'foreman_proxy' => [
    'custom_repo',
    'puppetca_modular',
    'realm_split_config_files',
    'use_autosignfile',
  ],
  'foreman_proxy::plugin::dhcp::infoblox' => [
    'use_ranges',
  ],
  'puppet' => [
    'agent_template',
    'main_template',
    'server_app_root',
    'server_ca_proxy',
    'server_directory_environments',
    'server_dynamic_environments',
    'server_environments',
    'server_http_allow',
    'server_httpd_service',
    'server_implementation',
    'server_main_template',
    'server_passenger',
    'server_passenger_min_instances',
    'server_passenger_pre_start',
    'server_passenger_ruby',
    'server_rack_arguments',
    'server_service_fallback',
    'server_template',
  ],
}.freeze

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

DELETED.each do |mod, parameters|
  mod_answers = answers[mod]
  next unless mod_answers.is_a?(Hash)

  parameters.each do |parameter|
    mod_answers.delete(parameter)
  end
end

CLEAR.each do |mod, parameters|
  mod_answers = answers[mod]
  next unless mod_answers.is_a?(Hash)

  parameters.each do |parameter|
    mod_answers[parameter] = nil if mod_answers[parameter]
  end
end

if (mod_answers = answers['foreman_proxy'])
  mod_answers['dhcp_gateway'] = nil if mod_answers['dhcp_gateway'] == '192.168.100.1'
end
