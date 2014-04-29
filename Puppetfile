forge 'http://forge.puppetlabs.com'

# Temporary for Amazon Linux support (https://github.com/puppetlabs/puppetlabs-xinetd/issues/32)
mod 'puppetlabs/xinetd',        :git => 'https://github.com/puppetlabs/puppetlabs-xinetd',
                                :ref => '45acf010700044f806ddbd141afa03f8ebbc1881'

# Temporary fix for Ubuntu 14.04
mod 'theforeman/apache',        :git => 'https://github.com/theforeman/puppetlabs-apache', :ref => 'fixes_ubuntu_1404'

# Dependencies
mod 'puppetlabs/mysql',         '>= 2.2.3 < 2.3.0'
mod 'puppetlabs/postgresql',    '>= 3.3.3 < 3.4.0'
mod 'theforeman/concat_native', '>= 1.3.1 < 1.4.0'
mod 'theforeman/dhcp',          '>= 1.3.1 < 1.4.0'
mod 'theforeman/dns',           '>= 1.4.0 < 1.5.0'
mod 'theforeman/git',           '>= 1.3.0 < 1.4.0'
mod 'theforeman/tftp',          '>= 1.4.1 < 1.5.0'

# Top-level modules
mod 'theforeman/foreman',       '>= 2.1.0 < 2.2.0'
mod 'theforeman/foreman_proxy', '>= 1.6.0 < 1.7.0'
mod 'theforeman/puppet',        '>= 2.1.0 < 2.2.0'
