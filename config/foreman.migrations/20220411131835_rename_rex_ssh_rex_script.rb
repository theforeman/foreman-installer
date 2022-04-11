if answers.key?('foreman_proxy::plugin::remote_execution::ssh')
  answers['foreman_proxy::plugin::remote_execution::script'] = answers.delete('foreman_proxy::plugin::remote_execution::ssh')
end
