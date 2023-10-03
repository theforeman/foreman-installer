# theforeman/certs can't deal with password changes
# This partially works around it by introducing a worflow where the cache file
# is removed, but the store exists it removes the store
if !app_value(:noop) && module_enabled?('katello')
  cache_dir = '/opt/puppetlabs/puppet/cache/foreman_cache_data'
  certs_dir = '/etc/candlepin/certs'
  ['keystore', 'truststore'].each do |store|
    unless File.exist?(File.join(cache_dir, "#{store}_password-file"))
      FileUtils.rm_f(File.join(certs_dir, store))
    end
  end
end
