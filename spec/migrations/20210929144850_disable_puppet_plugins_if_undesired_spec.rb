require 'spec_helper'

migration '20210929144850_disable_puppet_plugins_if_undesired' do
  let(:answers) do
    {
      'foreman' => false,
      'foreman::cli' => false,
    }
  end

  scenarios %w[foreman katello] do
    it 'keeps foreman::cli disabled' do
      expect(migrated_answers['foreman::cli']).to be false
    end

    it 'adds foreman::cli::puppet disabled' do
      expect(migrated_answers['foreman::cli::puppet']).to be false
    end

    it 'keeps foreman disabled' do
      expect(migrated_answers['foreman']).to be false
    end

    it 'adds foreman::plugin::puppet disabled' do
      expect(migrated_answers['foreman::plugin::puppet']).to be false
    end
  end
end
