unless app_value(:noop)
  if File.exist?('/opt/puppetlabs/puppet/bin/ruby') && execute("rpm -q puppet-agent-oauth", false, false)
    unless execute("/opt/puppetlabs/puppet/bin/ruby -e \"require 'oauth'\"", false, false)
      execute("yum -y reinstall puppet-agent-oauth")
    end
  end
end
