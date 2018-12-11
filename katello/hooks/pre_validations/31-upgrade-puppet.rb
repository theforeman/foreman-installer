unless app_value(:noop)
  Kafo::Helpers.log_and_say :info, 'Resetting puppet server version param...'

  if File.exist?('/opt/puppetlabs/puppet/bin/ruby') && Kafo::Helpers.execute("rpm -q puppet-agent-oauth", false, false)
    unless Kafo::Helpers.execute("/opt/puppetlabs/puppet/bin/ruby -e \"require 'oauth'\"", false, false)
      Kafo::Helpers.execute("yum -y reinstall puppet-agent-oauth")
    end
  end

  if puppetserver_version_param = param('puppet', 'server_puppetserver_version')
    puppetserver_version_param.unset_value
  end

  if puppetserver_metrics_param = param('puppet', 'server_puppetserver_metrics')
    puppetserver_metrics_param.unset_value
  end
end
