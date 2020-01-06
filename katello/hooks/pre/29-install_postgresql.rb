# Working around https://tickets.puppetlabs.com/browse/PUP-2169
if local_postgresql? && facts[:os][:release][:major] == '7' && !app_value(:upgrade)
  ensure_package('rh-postgresql10-postgresql-server', 'installed')
end
