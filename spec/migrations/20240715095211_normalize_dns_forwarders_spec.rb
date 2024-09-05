require 'spec_helper'

migration '20240715095211_normalize_dns_forwarders' do
  scenarios %w[foreman katello foreman-proxy-content] do
    context 'valid array' do
      let(:answers) do
        {
          'foreman_proxy' => {
            'dns_forwarders' => ['192.0.2.1', '192.0.2.2'],
          },
        }
      end

      it 'leaves the answers untouched' do
        expect(migrated_answers['foreman_proxy']['dns_forwarders']).to eq(['192.0.2.1', '192.0.2.2'])
      end
    end

    context 'semicolon separated value' do
      let(:answers) do
        {
          'foreman_proxy' => {
            'dns_forwarders' => ['192.0.2.1; 192.0.2.2'],
          },
        }
      end

      it 'normalizes the answer' do
        expect(migrated_answers['foreman_proxy']['dns_forwarders']).to eq(['192.0.2.1', '192.0.2.2'])
      end
    end
  end
end
