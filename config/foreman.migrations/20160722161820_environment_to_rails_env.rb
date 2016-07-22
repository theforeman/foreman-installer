# rename foreman environment parameter to rails_env
# https://github.com/theforeman/puppet-foreman_proxy/commit/d239f0b
answers['foreman']['rails_env'] = answers['foreman'].delete('environment') if answers['foreman'] && answers['foreman'].has_key?('environment')
