unless app_value(:noop)
  if File.exist?('/opt/puppetlabs/puppet/bin/ruby') && execute_command("rpm -q puppet-agent-oauth", false, false)
    unless execute_command("/opt/puppetlabs/puppet/bin/ruby -e \"require 'oauth'\"", false, false)
      execute_command("yum -y reinstall puppet-agent-oauth", false, true)
    end
  end
end
