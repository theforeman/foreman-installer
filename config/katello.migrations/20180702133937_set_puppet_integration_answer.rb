if answers['foreman_proxy_content'].is_a?(Hash)
  enabled = answers['puppet'].is_a?(Hash) && answers['puppet']['server'] != false && answers['puppet']['server_foreman'] != false
  answers['foreman_proxy_content']['puppet'] = false unless enabled
end
