# Rename foreman_proxy puppetrun parameters to puppet
# https://github.com/theforeman/puppet-foreman_proxy/commit/c26cac15
migrate_module('foreman_proxy') do |mod|
  mod.rename_parameter('puppetrun', 'puppet')
  mod.rename_parameter('puppetrun_listen_on', 'puppet_listen_on')
end
