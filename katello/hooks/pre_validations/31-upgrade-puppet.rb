unless app_value(:noop)
  if File.exist?('/opt/puppetlabs/puppet/bin/ruby') && Kafo::Helpers.execute("rpm -q puppet-agent-oauth", false, false)
    unless Kafo::Helpers.execute("/opt/puppetlabs/puppet/bin/ruby -e \"require 'oauth'\"", false, false)
      Kafo::Helpers.execute("yum -y reinstall puppet-agent-oauth")
    end
  end
end
