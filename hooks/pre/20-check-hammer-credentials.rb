require 'yaml'
require 'fileutils'

NEW_HAMMER_CONFIG_PATH = '/root/.hammer/cli.modules.d'
NEW_HAMMER_CONFIG_FILE = 'foreman.yml'
POSSIBLE_RECENT_CONFIG_PATHS = [
  '/etc/hammer/cli_config.yml',
  '/etc/hammer/cli.modules.d/foreman.yml',
  '/root/.hammer/cli_config.yml'
]

def password_set?(path)
  if File.exist?(path)
    config = YAML.load_file(path)
    return true if config[:foreman].is_a?(::Hash) && (config[:foreman][:username] != 'admin' || config[:foreman][:password])
  end
  false
end

new_config_file = File.join(NEW_HAMMER_CONFIG_PATH, NEW_HAMMER_CONFIG_FILE)
unless File.exist?(new_config_file)
  # if there is foreman password or non-admin user set in any of the legacy configs
  # create empty hammer foreman config to prevent installer from creating new one
  if POSSIBLE_RECENT_CONFIG_PATHS.any? { |path| password_set?(path) }
    FileUtils.mkdir_p(NEW_HAMMER_CONFIG_PATH)
    File.open(new_config_file, "w+") do |file|
      file.write("---\n:foreman: {}\n")
    end
  end
end
