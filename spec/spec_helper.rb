require 'kafo'
require 'rspec'
require 'yaml'

CONFIG_DIR = File.expand_path(File.join(__dir__, '..', 'config'))
FIXTURE_DIR = File.expand_path(File.join(__dir__, 'fixtures'))

def config_path(filename)
  File.join(CONFIG_DIR, filename)
end

def load_config_yaml(filename)
  YAML.load_file(config_path(filename))
end

def fixture_path(directory, filename)
  File.join(FIXTURE_DIR, directory, filename)
end

def load_fixture_yaml(directory, filename)
  YAML.load_file(fixture_path(directory, filename))
end

RSpec.shared_context 'with migrations', type: :migrations do
  subject(:migrator) { Kafo::Migrations.new(migrations).run(config, answers) }

  let(:config) { load_config_yaml("#{scenario_name}.yaml") }
  let(:answers) { load_config_yaml("#{scenario_name}-answers.yaml") }
  let(:migrations) { config_path("#{scenario_name}.migrations") }

  let(:migrated_config) { migrator[0] }
  let(:migrated_answers) { migrator[1] }

  def self.scenarios(scenarios, &block)
    scenarios.each do |scenario_name|
      context "with scenario #{scenario_name}" do
        let(:scenario_name) { scenario_name }

        class_exec(&block)
      end
    end
  end
end

RSpec.configure do |c|
  c.before(:suite) { Kafo::KafoConfigure.logger = Logger.new('test.log') }
  c.alias_example_group_to :migration, type: :migrations
end
