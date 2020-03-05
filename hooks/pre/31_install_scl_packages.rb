# Working around https://tickets.puppetlabs.com/browse/PUP-2169
if el7?
  packages = []
  packages << 'rh-postgresql12-postgresql-server' if local_postgresql?
  packages << 'rh-redis5-redis' if local_redis?
  packages << 'pulpcore-selinux' if pulpcore_enabled?
  ensure_packages(packages, 'installed')
end
