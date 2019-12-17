# Working around https://tickets.puppetlabs.com/browse/PUP-2169
if el7? && local_redis?
  ensure_package('rh-redis5-redis', 'installed')
end
