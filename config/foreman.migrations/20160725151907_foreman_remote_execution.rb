answers['foreman::plugin::remote_execution'] ||= false
scenario[:mapping][:'foreman::plugin::remote_execution'] ||= {:dir_name => 'foreman', :manifest_name => 'plugin/remote_execution'}

answers['foreman_proxy::plugin::remote_execution::ssh'] ||= false
scenario[:mapping][:'foreman_proxy::plugin::remote_execution::ssh'] ||= {:dir_name => 'foreman_proxy', :manifest_name => 'plugin/remote_execution/ssh', :params_name => 'plugin/remote_execution/ssh/params'}
