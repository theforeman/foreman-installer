if answers['foreman_proxy_content'].is_a?(Hash) && answers['foreman_proxy_content'].key?('pulpcore_cache_enabled')
  answers['foreman_proxy_content']['pulpcore_cache_enabled'] = true
end
