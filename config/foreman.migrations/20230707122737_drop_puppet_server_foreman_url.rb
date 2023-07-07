if answers['puppet'].is_a?(Hash) && answers['foreman_proxy'].is_a?(Hash) && answers['puppet']['server_foreman_url'] == answers['foreman_proxy']['foreman_base_url']
  answers['puppet'].delete('server_foreman_url')
end
