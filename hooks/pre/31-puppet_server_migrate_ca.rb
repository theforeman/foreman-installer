# In Puppetserver 7 the ca directory has moved from
# /etc/puppetlabs/puppet/ssl/ca to /etc/puppetlabs/puppetserver/ca
# There is a command (puppetserver ca migrate) to migrate, but this requires
# the server to be stopped. The Puppet module can execute the migration, but
# can't stop the service.
stdout_stderr, _status = execute_command('puppetserver --version', false, true)
stdout_stderr&.match(/puppetserver version: (?<version>\d+)\.\d+\.\d+/) do |match|
  old_ca_dir = '/etc/puppetlabs/puppet/ssl/ca'
  if m[:version] == '7' && File.directory?(old_ca_dir) && !File.symlink?(old_ca_dir)
    if app_value(:noop)
      logger.debug 'Would stop puppetserver.service to migrate CA directory'
    else
      stop_services(['puppetserver.service'])
    end
  end
end
