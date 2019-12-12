unless app_value(:noop)
  if File.exist?('/opt/puppetlabs/puppet/bin/ruby') && system("rpm -q puppet-agent-oauth")
    unless system("/opt/puppetlabs/puppet/bin/ruby -e \"require 'oauth'\"")
      execute("yum -y reinstall puppet-agent-oauth")
    end
  end
end
