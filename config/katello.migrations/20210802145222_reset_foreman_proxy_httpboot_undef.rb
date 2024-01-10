# https://github.com/theforeman/puppet-foreman_proxy/commit/e4b7763e45fecc5fbaa5d88cc066906d6caf7bf7
# changed httpboot from Optional[Boolean] to Boolean
if answers['foreman_proxy'].is_a?(Hash) && answers['foreman_proxy']['httpboot'].nil?
  answers['foreman_proxy'].delete('httpboot')
end
