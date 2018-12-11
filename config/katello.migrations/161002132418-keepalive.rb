if answers['foreman'].is_a?(Hash)
  answers['foreman']['keepalive'] = true
  answers['foreman']['max_keepalive_requests'] = answers['katello']['max_keep_alive'] || 10_000
end
