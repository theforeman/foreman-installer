# The server.xml file contained the passwords world readable
# Purging them will regenerate them
FileUtils.rm_f('/opt/puppetlabs/puppet/cache/foreman_cache_data/keystore_password-file')
FileUtils.rm_f('/opt/puppetlabs/puppet/cache/foreman_cache_data/truststore_password-file')
