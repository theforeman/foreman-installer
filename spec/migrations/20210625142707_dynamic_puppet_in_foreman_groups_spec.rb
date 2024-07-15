require 'spec_helper'

migration '20210625142707_dynamic_puppet_in_foreman_groups' do
  let(:answers) do
    {
      'foreman' => {
        'user_groups' => ['puppet'],
      },
    }
  end

  scenarios %w[foreman katello] do
    it 'removes puppet' do
      expect(migrated_answers['foreman']['user_groups']).to eq []
    end
  end
end
