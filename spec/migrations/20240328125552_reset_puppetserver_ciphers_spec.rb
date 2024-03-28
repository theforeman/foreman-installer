require 'spec_helper'

migration '20231005004305_redis_default_cache' do
  scenarios %w[foreman katello foreman-proxy-content] do
    context 'current ciphers' do
      let(:answers) do
        {
          'puppet' => {
            'server_cipher_suites' => [
              'TLS_DHE_RSA_WITH_AES_128_GCM_SHA256',
              'TLS_DHE_RSA_WITH_AES_256_GCM_SHA384',
              'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256',
              'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384',
              'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256',
              'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384',
            ],
          },
        }
      end

      it 'leaves ciphers untouched' do
        expect(migrated_answers['puppet']['server_cipher_suites']).not_to be_nil
      end
    end

    context 'outdated ciphers' do
      let(:answers) do
        {
          'puppet' => {
            'server_cipher_suites' => [
              'TLS_RSA_WITH_AES_256_CBC_SHA256',
              'TLS_RSA_WITH_AES_256_CBC_SHA',
              'TLS_RSA_WITH_AES_128_CBC_SHA256',
              'TLS_RSA_WITH_AES_128_CBC_SHA',
            ],
          },
        }
      end

      it 'resets the answer' do
        expect(migrated_answers['puppet']['server_cipher_suites']).to be_nil
      end
    end
  end
end
