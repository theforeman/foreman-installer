forge 'https://forgeapi.puppetlabs.com'

# Dependencies
mod 'puppet/extlib',            '<= 0.11.3'
mod 'puppetlabs/mysql',         '>= 3.8.0'
mod 'puppetlabs/postgresql',    '>= 4.8.0'
mod 'puppetlabs/puppetdb'
mod 'theforeman/dhcp',          :git => 'https://github.com/theforeman/puppet-dhcp'
mod 'theforeman/dns',           :git => 'https://github.com/theforeman/puppet-dns'
mod 'theforeman/git',           :git => 'https://github.com/theforeman/puppet-git'
mod 'theforeman/tftp',          :git => 'https://github.com/theforeman/puppet-tftp'

# From git until PassengerMaxInstancesPerApp is available in released version
#   https://github.com/puppetlabs/puppetlabs-apache/commit/d14e1a83e7e778fc6a000f8b28124fdb36834c43
mod 'puppetlabs/apache',        :git => 'https://github.com/theforeman/puppetlabs-apache.git', :ref => '1.10.x'

# Top-level modules
mod 'theforeman/foreman',       :git => 'https://github.com/theforeman/puppet-foreman'
mod 'theforeman/foreman_proxy', :git => 'https://github.com/theforeman/puppet-foreman_proxy'
mod 'theforeman/puppet',        :git => 'https://github.com/theforeman/puppet-puppet'
