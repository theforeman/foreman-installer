forge 'https://forgeapi.puppetlabs.com'

# Dependencies
mod 'puppet/extlib',            '<= 0.11.3'
mod 'puppetlabs/mysql',         '>= 3.8.0'
mod 'puppetlabs/postgresql',    '>= 4.8.0'
mod 'puppetlabs/puppetdb'
mod 'theforeman/dhcp',          '>= 3.0.0 < 3.1.0'
mod 'theforeman/dns',           '>= 4.0.0 < 4.1.0'
mod 'theforeman/git',           '>= 2.0.0 < 2.1.0'
mod 'theforeman/tftp',          '>= 2.0.0 < 2.1.0'

# From git until PassengerMaxInstancesPerApp is available in released version
#   https://github.com/puppetlabs/puppetlabs-apache/commit/d14e1a83e7e778fc6a000f8b28124fdb36834c43
mod 'puppetlabs/apache',        :git => 'https://github.com/theforeman/puppetlabs-apache.git', :ref => '1.10.x'

# Top-level modules
mod 'theforeman/foreman',       '>= 7.0.0 < 7.1.0'
mod 'theforeman/foreman_proxy', '>= 5.0.0 < 5.1.0'
mod 'theforeman/puppet',        '>= 7.0.0 < 7.1.0'
