if answers['puppet'].is_a?(Hash)
  puppet = answers['puppet']
  puppet['server_puppetserver_version'] = nil if puppet['server_puppetserver_version']
  puppet['server_puppetserver_metrics'] = nil if puppet['server_puppetserver_metrics']

  if ['-XX:MaxPermSize=256m', '-Djruby.logger.class=com.puppetlabs.jruby_utils.jruby.Slf4jLogger'].include?(puppet['server_jvm_extra_args'])
    server['server_jvm_extra_args'] = nil
  end
end
