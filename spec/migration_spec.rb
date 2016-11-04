require 'spec_helper'
require 'yaml'
require 'kafo'

CONFIG_DIR = File.expand_path(File.join(__FILE__, "../../config"))
Kafo::KafoConfigure.logger = Logger.new("test.log")

describe 'migrations' do
  %w(foreman).each do |scenario_name|
    context "on #{scenario_name}" do

      let(:scenario) do
        {
          :answers    => YAML.load_file(File.expand_path(File.join(CONFIG_DIR, "#{scenario_name}-answers.yaml"))),
          :config     => YAML.load_file(File.expand_path(File.join(CONFIG_DIR, "#{scenario_name}.yaml"))),
          :migrations => File.expand_path(File.join(CONFIG_DIR, "#{scenario_name}.migrations"))
        }
      end

      let(:migrator) { Kafo::Migrations.new(scenario[:migrations]).run(scenario[:config].dup, scenario[:answers].dup) }

      it 'does not change scenario config' do
        after, = migrator
        expect(scenario[:config]).to eq after
      end

      it 'does not change scenario answers' do
        _, after = migrator
        expect(scenario[:answers]).to eq after
      end
    end
  end
end
