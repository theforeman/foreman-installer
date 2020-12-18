# Since #31385 the ciphers are now always set
if answers['foreman_proxy_content'].is_a?(Hash) && answers['foreman_proxy_content']['qpid_router_ssl_ciphers'].nil?
  answers['foreman_proxy_content'].delete('qpid_router_ssl_ciphers')
end
