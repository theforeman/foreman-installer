require 'spec_helper'

migration 'all migrations' do
  scenarios %w[foreman foreman-proxy-content katello] do
    it 'does not change the scenario config' do
      expect(migrated_config).to eq load_config_yaml("#{scenario_name}.yaml")
    end

    it 'does not change the scenario answers' do
      expect(migrated_answers).to eq load_config_yaml("#{scenario_name}-answers.yaml")
    end
  end

  scenarios %w[katello] do
    let(:answers) { load_fixture_yaml(fixture, "#{scenario_name}-answers-before.yaml") }
    let(:expected_answers) { load_fixture_yaml(fixture, "#{scenario_name}-answers-after.yaml") }

    ['pulpcore-migration', 'pulpcore-migration-rpm-only', 'pulpcore-migration-dont-use-content-plugins-on-upgrades'].each do |fixture_name|
      context "with fixture #{fixture_name}" do
        let(:fixture) { fixture_name }

        it 'matches the answers fixture' do
          expect(migrated_answers).to eq expected_answers
        end
      end
    end
  end
end
