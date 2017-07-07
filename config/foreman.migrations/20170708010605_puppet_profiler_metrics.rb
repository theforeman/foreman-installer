# server_puppetserver_metrics also controls if the Ruby profiler gets enabled
# in puppet-puppet since 94ff77740a27d458ce1444db016645ab763cba42
if answers['puppet'] && answers['puppet'].has_key?('server_enable_ruby_profiler')
  if answers['puppet']['server_enable_ruby_profiler'] == true
    answers['puppet']['server_puppetserver_metrics'] = true
  end
  answers['puppet'].delete('server_enable_ruby_profiler')
end
