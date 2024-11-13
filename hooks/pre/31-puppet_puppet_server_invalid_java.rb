# With Puppetserver 8 the minimum java version has been increased to Java 11
# If the user is upgrading from Puppet 7 to Puppet 8 then /usr/bin/java may
# point to Java 8, which is what Puppetserver uses by default. The installer
# will explicitly configure Java 17, but puppetserver.service can end up in a
# restart loop where puppet can't properly restart the service.
#
# This hook detects Java 8 and Puppetserver 8 and explicitly stops the service.
# The installer should then reconfigure it and start it again.
#
# See https://github.com/theforeman/puppet-puppet/pull/910 which is currently
# only implemented for Red Hat based systems.
sysconfig_file = '/etc/sysconfig/puppetserver'
if File.exist?(sysconfig_file)
  puppetserver_stdout_stderr, _status = execute_command('puppetserver --version', false, true)
  puppetserver_stdout_stderr&.match(/puppetserver version: (?<version>\d+)\.\d+\.\d+/) do |puppetserver_match|
    logger.debug("Found Puppetserver #{puppetserver_match[:version]}")
    if puppetserver_match[:version] == '8'
      java_stdout_stderr, _status = execute_command("source #{sysconfig_file} ; $JAVA_BIN -version", false, true)
      parse_java_version(java_stdout_stderr) do |java_version|
        if java_version < 11
          logger.info "Detected Java #{java_version} which is too old for Puppetserver #{puppetserver_match[:version]}"
          if app_value(:noop)
            logger.debug 'Would stop puppetserver.service'
          else
            stop_services(['puppetserver.service'])
          end
        end
      end
    end
  end
end
