# Working around https://tickets.puppetlabs.com/browse/PUP-2169
if local_postgresql? && facts[:os][:release][:major] == '7' && !app_value(:upgrade)
  package = 'rh-postgresql10-postgresql-server'

  `rpm -q #{package}`

  unless $?.success?
    Kafo::Helpers.execute("yum -y install #{package}")
  end
end
