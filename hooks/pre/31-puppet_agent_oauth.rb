unless app_value(:noop)
  if File.exist?('/opt/puppetlabs/puppet/bin/ruby') && execute("rpm -q puppet-agent-oauth", false, false)
    unless execute("/opt/puppetlabs/puppet/bin/ruby -e \"require 'oauth'\"", false, false)
      success = execute("yum -y reinstall puppet-agent-oauth", false, true)

      logger.error("Failed to reinstall puppet-agent-oauth. Please check that the package is available from a repository.") unless success
    end
  end
end
