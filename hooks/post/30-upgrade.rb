if !app_value(:noop) && [0, 2].include?(@kafo.exit_code) && foreman_server?
  execute('foreman-rake upgrade:run')
end
