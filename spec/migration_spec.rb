require 'spec_helper'

describe 'migrations' do
  %w(foreman foreman-proxy-content katello).each do |scenario_name|
    context "on #{scenario_name}" do
      let(:answers) { load_config_yaml("#{scenario_name}-answers.yaml") }
      let(:config) { load_config_yaml("#{scenario_name}.yaml") }
      let(:scenario) do
        {
          :answers    => load_config_yaml("#{scenario_name}-answers.yaml"),
          :config     => load_config_yaml("#{scenario_name}.yaml"),
          :migrations => config_path("#{scenario_name}.migrations")
        }
      end

      let(:migrator) { Kafo::Migrations.new(scenario[:migrations]).run(scenario[:config], scenario[:answers]) }

      it 'does not change scenario config' do
        after, = migrator
        expect(config).to eq after
      end

      it 'does not change scenario answers' do
        _, after = migrator
        expect(answers).to eq after
      end
    end
  end

  %w(katello).each do |scenario_name|
    context "on #{scenario_name} migrated from Foreman 1.21" do
      let(:answers) { load_config_yaml("#{scenario_name}-answers.yaml") }
      let(:config) { load_config_yaml("#{scenario_name}.yaml") }
      let(:scenario) do
        {
          :answers    => load_fixture_yaml("foreman-1.21", "#{scenario_name}-answers.yaml"),
          :config     => load_fixture_yaml("foreman-1.21", "#{scenario_name}.yaml"),
          :migrations => config_path("#{scenario_name}.migrations")
        }
      end

      let(:migrator) { Kafo::Migrations.new(scenario[:migrations]).run(scenario[:config], scenario[:answers]) }

      it 'does not change scenario config' do
        after, = migrator
        expect(config).to eq after
      end

      it 'does not change scenario answers' do
        _, after = migrator
        expect(answers).to eq after
      end
    end
  end
end
