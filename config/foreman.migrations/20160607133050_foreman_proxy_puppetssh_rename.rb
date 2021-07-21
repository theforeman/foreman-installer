# Rename foreman_proxy provider "puppetssh" to "ssh"
# http://projects.theforeman.org/issues/15323
migrate_module('foreman_proxy') do |mod|
  mod['puppetrun_provider'] = 'ssh' if mod['puppetrun_provider'] == 'puppetssh'
end
