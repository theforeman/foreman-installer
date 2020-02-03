if foreman_server?
  execute('foreman-rake upgrade:run')
end
