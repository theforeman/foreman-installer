# server_ssl_chain_filepath changed its default to undef, clear old default
# https://github.com/theforeman/puppet-puppet/commit/818bf005b2a1b0f48896c5c9db9afbcf59aadb1c
if answers['puppet'].is_a?(Hash) && answers['puppet']['server_ssl_chain_filepath'] == '/etc/puppetlabs/puppet/ssl/ca/ca_crt.pem'
  answers['puppet'].delete('server_ssl_chain_filepath')
end
