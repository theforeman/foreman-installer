require 'spec_helper'

migration '20211108174119_disable_registration_without_templates' do
  scenarios %w[foreman foreman-proxy-content katello] do
    context 'with registration, without templates' do
      let(:answers) do
        {
          'foreman_proxy' => {
            'registration' => true,
            'templates' => false,
          },
        }
      end

      it 'disables registration' do
        expect(migrated_answers['foreman_proxy']['registration']).to be false
      end
    end

    context 'with registration, with templates' do
      let(:answers) do
        {
          'foreman_proxy' => {
            'registration' => true,
            'templates' => true,
          },
        }
      end

      it 'keeps registration enabled' do
        expect(migrated_answers['foreman_proxy']['registration']).to be true
      end
    end
  end
end
