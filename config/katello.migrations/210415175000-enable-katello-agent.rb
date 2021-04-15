if answers['foreman_proxy_content'].is_a?(Hash) && answers['foreman_proxy_content'].key?('qpid_router')
  answers['foreman_proxy_content']['enable_katello_agent'] = answers['foreman_proxy_content'].delete('qpid_router')
end
