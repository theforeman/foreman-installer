def oauth_aio_gem_installed?
  return false unless File.exist?('/opt/puppetlabs/puppet/bin/ruby')

  case facts[:os][:family]
  when 'Debian'
    execute("dpkg-query --show --showformat='${db:Status-Status}' puppet-agent-oauth | grep -q '^installed'", false, false)
  when 'RedHat'
    execute("rpm -q puppet-agent-oauth", false, false)
  end
end

def oauth_aio_gem_works?
  execute("/opt/puppetlabs/puppet/bin/ruby -e \"require 'oauth'\"", false, false)
end

def reinstall_oauth_aio_gem
  case facts[:os][:family]
  when 'Debian'
    execute("apt-get --reinstall install puppet-agent-oauth", false, true)
  when 'RedHat'
    execute("yum -y reinstall puppet-agent-oauth", false, true)
  end
end

if oauth_aio_gem_installed? && !oauth_aio_gem_works?
  if app_value(:noop)
    logger.error('Detected broken puppet-agent-oauth; needs reinstall')
  else
    logger.debug('Detected broken puppet-agent-oauth; reinstalling')
    success = reinstall_oauth_aio_gem

    logger.error("Failed to reinstall puppet-agent-oauth. Please check that the package is available from a repository.") unless success
  end
end
