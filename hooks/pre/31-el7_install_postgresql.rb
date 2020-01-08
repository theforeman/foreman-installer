# Working around https://tickets.puppetlabs.com/browse/PUP-2169
if local_postgresql? && el7?
  ensure_package('rh-postgresql12-postgresql-server', 'installed')
end
