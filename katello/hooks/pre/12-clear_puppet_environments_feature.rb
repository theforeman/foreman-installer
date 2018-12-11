# See bottom of the script for the command that kicks off the script

PUPPET_THREE_ENV_DIR = '/etc/puppet/environments'
PUPPET_FOUR_ENV_DIR = '/etc/puppetlabs/code/environments'

def clear_puppet_environments
  [PUPPET_THREE_ENV_DIR, PUPPET_FOUR_ENV_DIR].each do |env_dir|
    if File.directory?(env_dir)
      `rm -rf #{File.join(env_dir, '*')}`
      Kafo::KafoConfigure.logger.info "Puppet environment data successfully removed from #{env_dir}."
    else
      Kafo::KafoConfigure.logger.info "Puppet environment data directory not present at #{env_dir}."
    end
  end
end

clear_puppet_environments if app_value(:clear_puppet_environments) && !app_value(:noop)
