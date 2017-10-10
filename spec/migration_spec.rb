require 'spec_helper'
require 'yaml'
require 'kafo'

CONFIG_DIR = File.expand_path(File.join(__FILE__, "../../config"))
Kafo::KafoConfigure.logger = Logger.new("test.log")

describe 'migrations' do
  %w(foreman).each do |scenario_name|
    context "on #{scenario_name}" do
      let(:answers) do
        YAML.load_file(File.expand_path(File.join(CONFIG_DIR, "#{scenario_name}-answers.yaml")))
      end

      let(:config) do
        YAML.load_file(File.expand_path(File.join(CONFIG_DIR, "#{scenario_name}.yaml")))
      end

      let(:scenario) do
        {
          :answers    => YAML.load_file(File.expand_path(File.join(CONFIG_DIR, "#{scenario_name}-answers.yaml"))),
          :config     => YAML.load_file(File.expand_path(File.join(CONFIG_DIR, "#{scenario_name}.yaml"))),
          :migrations => File.expand_path(File.join(CONFIG_DIR, "#{scenario_name}.migrations"))
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
