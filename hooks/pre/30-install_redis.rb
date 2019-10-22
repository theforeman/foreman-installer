# Working around https://tickets.puppetlabs.com/browse/PUP-2169
if facts[:os][:release][:major] == '7' && !app_value(:upgrade)
  ensure_package('rh-redis5-redis', 'installed')
end
