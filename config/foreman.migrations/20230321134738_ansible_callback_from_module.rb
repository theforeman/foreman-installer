# https://github.com/theforeman/puppet-foreman_proxy/commit/946a422baf57726d5f189a6eecad6f3a30cbd84c
if answers['foreman_proxy::plugin::ansible'].is_a?(Hash) && answers['foreman_proxy::plugin::ansible']['callback'] == 'foreman'
  answers['foreman_proxy::plugin::ansible']['callback'] = 'theforeman.foreman.foreman'
end
