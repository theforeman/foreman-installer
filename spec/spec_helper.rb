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

RSpec.configure do |c|
  c.before(:suite) { Kafo::KafoConfigure.logger = Logger.new('test.log') }
end
