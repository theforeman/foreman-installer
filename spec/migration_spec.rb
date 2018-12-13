require 'spec_helper'

describe 'migrations' do
  %w(foreman).each do |scenario_name|
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
end
