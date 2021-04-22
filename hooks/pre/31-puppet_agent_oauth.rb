unless app_value(:noop)
  if File.exist?('/opt/puppetlabs/puppet/bin/ruby') && execute("rpm -q puppet-agent-oauth", false, false)
    unless execute("/opt/puppetlabs/puppet/bin/ruby -e \"require 'oauth'\"", false, false)
      success = execute("yum -y reinstall puppet-agent-oauth", false, true)

      logger.error("Failed to reinstall puppet-agent-oauth. Please check that the package is available from a repository.") unless success
    end
  end
  if File.exist?('/opt/puppetlabs/puppet/bin/ruby') && execute("dpkg-query --show --showformat='${db:Status-Status}' puppet-agent-oauth | grep -q '^installed'", false, false)
    unless execute("/opt/puppetlabs/puppet/bin/ruby -e \"require 'oauth'\"", false, false)
      success = execute("apt-get --reinstall install puppet-agent-oauth", false, true)

      logger.error("Failed to reinstall puppet-agent-oauth. Please check that the package is available from a repository.") unless success
    end
  end
end
