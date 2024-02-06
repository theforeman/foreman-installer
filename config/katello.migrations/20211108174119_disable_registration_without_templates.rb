# In Foreman 3.1 the registration module requires templates where it previously
# worked standalone.
# https://github.com/theforeman/puppet-foreman_proxy/commit/6f64423e7ca25c8b58f8da4d371172c22eb9b0e3
if answers['foreman_proxy'].is_a?(Hash) && answers['foreman_proxy']['registration'] && !answers['foreman_proxy']['templates']
  answers['foreman_proxy']['registration'] = false
end
