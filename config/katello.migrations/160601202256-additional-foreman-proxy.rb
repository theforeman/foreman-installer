def move(name, default=nil, new_name=nil)
  return unless answers['capsule'].key?(name)
  answers['foreman_proxy'][(new_name || name)] = answers['capsule'].delete(name) { |k| default }
end

# migrate from legacy capsule, if exists
if answers['capsule'].is_a? Hash
  unless answers['capsule']['parent_fqdn'].nil?
    answers['foreman_proxy']['trusted_hosts'] ||= []
    answers['foreman_proxy']['trusted_hosts'] << answers['capsule']['parent_fqdn']
    answers['foreman_proxy']['trusted_hosts'].uniq!
    answers['foreman_proxy']['foreman_base_url'] = "https://#{answers['capsule']['parent_fqdn']}"
  end

  move('foreman_oauth_key', 'admin', 'oauth_consumer_key')
  move('foreman_oauth_secret', 'admin', 'oauth_consumer_secret')
end

# migrate from legacy certs, if exists
if answers['certs'].is_a? Hash
  unless answers['certs']['node_fqdn'].nil?
    answers['foreman_proxy']['trusted_hosts'] ||= []
    answers['foreman_proxy']['trusted_hosts'] << answers['certs']['node_fqdn']
    answers['foreman_proxy']['trusted_hosts'].uniq!
  end
end
