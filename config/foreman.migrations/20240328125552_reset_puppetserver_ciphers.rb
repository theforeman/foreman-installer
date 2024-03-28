# https://github.com/theforeman/puppet-puppet/commit/8cc4e3094d5bbd6d05d794e087816934e1697a87
old_ciphers = ['TLS_RSA_WITH_AES_256_CBC_SHA256', 'TLS_RSA_WITH_AES_256_CBC_SHA', 'TLS_RSA_WITH_AES_128_CBC_SHA256', 'TLS_RSA_WITH_AES_128_CBC_SHA']
if answers['puppet'].is_a?(Hash) && answers['puppet']['server_cipher_suites'] == old_ciphers
  answers['puppet'].delete('server_cipher_suites')
end
