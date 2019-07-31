forge 'https://forgeapi.puppetlabs.com'

# Needed because puppetlabs/inifile doesn't allow puppetlabs/translate 2.0.0
# https://github.com/puppetlabs/puppetlabs-inifile/pull/345
mod 'puppetlabs/inifile',
  :git => 'https://github.com/puppetlabs/puppetlabs-inifile',
  :ref => '220669f8707d386cf063c4f52bda8631e066e865'

# Dependencies
mod 'puppetlabs/mysql',              '>= 4.0.0'
mod 'puppetlabs/postgresql',         '>= 5.6.0'
mod 'puppetlabs/puppetdb'
mod 'theforeman/dhcp',               '>= 5.0.1 < 5.1.0'
mod 'theforeman/dns',                '>= 6.2.0 < 6.3.0'
mod 'theforeman/git',                '>= 6.0.1 < 6.1.0'
mod 'theforeman/tftp',               '>= 5.0.1 < 5.1.0'

# Katello dependencies
mod 'katello/candlepin',             '>= 7.0.1 < 7.1.0'
mod 'katello/pulp',                  '>= 6.2.0 < 6.3.0'
mod 'katello/qpid',                  '>= 6.0.0 < 6.1.0'

# Top-level modules
mod 'theforeman/foreman',            '>= 12.2.0 < 12.3.0'
mod 'theforeman/foreman_proxy',      '>= 12.0.0 < 12.1.0'
mod 'theforeman/puppet',             '>= 12.0.1 < 12.1.0'

# Top-level katello modules
mod 'katello/foreman_proxy_content', '>= 9.0.2 < 9.1.0'
mod 'katello/certs',                 '>= 6.0.1 < 6.1.0'
mod 'katello/katello',               '>= 11.0.0 < 11.1.0'
