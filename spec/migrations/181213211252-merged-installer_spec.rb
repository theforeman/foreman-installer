require 'spec_helper'

migration '181213211252-merged-installer' do
  let(:config) { load_fixture_yaml('merged-installer', "#{scenario_name}-before.yaml") }

  scenarios %w[foreman-proxy-content katello] do
    it 'matches the scenario fixture' do
      expect(migrated_config).to eq load_fixture_yaml('merged-installer', "#{scenario_name}-after.yaml")
    end
  end
end
