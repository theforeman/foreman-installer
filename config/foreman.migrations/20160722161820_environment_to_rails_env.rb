# rename foreman environment parameter to rails_env
# https://github.com/theforeman/puppet-foreman_proxy/commit/d239f0b
migrate_module('foreman') do |mod|
  mod.rename_parameter('environment', 'rails_env')
end
