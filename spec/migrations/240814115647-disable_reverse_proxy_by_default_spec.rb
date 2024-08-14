require 'spec_helper'

migration '240814115647-disable-reverse-proxy-by-default' do
  scenarios %w[foreman-proxy-content] do
    context 'reset reverse_proxy to default value to disable by default' do
      let(:answers) do
        {
          'foreman_proxy_content' => {
            'reverse_proxy' => true,
          },
        }
      end

      it 'removes the stored answer' do
        expect(migrated_answers['foreman_proxy_content']['reverse_proxy']).to eq(nil)
      end
    end
  end
end
