# Rename foreman_proxy puppetrun parameters to puppet
# https://github.com/theforeman/puppet-foreman_proxy/commit/c26cac15
if answers['foreman_proxy'].is_a?(Hash)
  answers['foreman_proxy']['puppet'] = answers['foreman_proxy'].delete('puppetrun') if answers['foreman_proxy'].has_key?('puppetrun')
  answers['foreman_proxy']['puppet_listen_on'] = answers['foreman_proxy'].delete('puppetrun_listen_on') if answers['foreman_proxy'].has_key?('puppetrun_listen_on')
end
