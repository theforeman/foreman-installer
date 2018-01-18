def puppet4_available?
  osfamily = %x{facter osfamily}.strip
  success = case osfamily
  when 'RedHat'
    ['puppet-agent', 'puppetserver'].map do |pkg|
      %x{yum info #{pkg} > /dev/null}
      $?.success?
    end
  when 'Debian'
    ['puppet-agent', 'puppetserver'].map do |pkg|
      %x{apt-cache show #{pkg} > /dev/null}
      $?.success?
    end
  else
    fail_and_exit "OS family '#{osfamily}' is not supported"
  end
  success.any? && !success.include?(false)
end

def upgrade_puppet_package
  Kafo::Helpers.execute('puppet resource package puppet-server ensure=absent')
  Kafo::Helpers.execute('puppet resource package puppet-agent ensure=installed')
end

def migrate_data
  # Using .default doesn't work since it's calculated with old facts (puppet
  # version)
  old_server_envs_dir = param('puppet', 'server_envs_dir').value
  new_server_envs_dir = '/etc/puppetlabs/code'

  old_ssldir = param('puppet', 'ssldir').value
  new_ssldir = '/etc/puppetlabs/puppet/ssl'

  old_vardir = param('puppet', 'vardir').value
  new_vardir = '/opt/puppetlabs/puppet/cache'

  success = []
  if old_server_envs_dir != new_server_envs_dir && File.directory?(old_server_envs_dir)
    success << Kafo::Helpers.execute("cp -rfp #{old_server_envs_dir} #{new_server_envs_dir}")
  end
  if old_ssldir != new_ssldir && File.directory?(old_ssldir)
    success << Kafo::Helpers.execute("cp -rfp #{old_ssldir} #{new_ssldir}")
  end
  if old_vardir != new_vardir && File.directory?("#{old_vardir}/foreman_cache_data")
    success << Kafo::Helpers.execute("cp -rfp #{old_vardir}/foreman_cache_data #{new_vardir}/")
  end
  !success.include?(false)
end

def upgrade_params
  params = {
    'foreman'       => ['client_ssl_ca', 'client_ssl_cert', 'client_ssl_key', 'puppet_home', 'puppet_ssldir', 'server_ssl_ca', 'server_ssl_cert', 'server_ssl_chain', 'server_ssl_crl', 'server_ssl_key', 'websockets_ssl_cert', 'websockets_ssl_key', ],
    'puppet'        => ['autosign', 'client_package', 'codedir', 'configtimeout', 'dir', 'logdir', 'rundir', 'ssldir', 'vardir', 'server_common_modules_path', 'server_default_manifest_path', 'server_dir', 'server_envs_dir', 'server_external_nodes', 'server_jruby_gem_home', 'server_package', 'server_puppetserver_dir', 'server_puppetserver_vardir', 'server_ruby_load_paths', 'server_ssl_dir'],
    'foreman_proxy' => ['puppet_ssl_ca', 'puppet_ssl_cert', 'puppet_ssl_key', 'puppetca_cmd', 'puppetdir', 'ssl_ca', 'ssl_cert', 'ssl_key', 'ssldir'],
  }

  unless app_value(:noop)
    params.each do |mod, names|
      names.each do |name|
        p = param(mod, name)
        fail_and_exit "Failed to find parameter '#{name}' in '#{mod}'" if p.nil?
        p.value = nil
      end
    end

    param('puppet', 'server_implementation').value = 'puppetserver'
  end
end

def upgrade_step(step)
  noop = app_value(:noop) ? ' (noop)' : ''

  Kafo::Helpers.log_and_say :info, "Upgrade Step: #{step}#{noop}..."
  unless app_value(:noop)
    status = send(step)
    fail_and_exit "Upgrade step #{step} failed. Check logs for more information." unless status
  end
end

def fail_and_exit(message)
  Kafo::Helpers.log_and_say :error, message
  kafo.class.exit 1
end

if app_value(:upgrade_puppet)
  fail_and_exit 'Puppet 3 to 4 upgrade is not currently supported for the chosen scenario.' unless Kafo::Helpers.module_enabled?(@kafo, 'puppet')

  Kafo::Helpers.log_and_say :info, 'Upgrading puppet...'
  fail_and_exit 'Unable to find Puppet 4 packages, is the repository enabled?' unless puppet4_available?

  upgrade_step :upgrade_puppet_package
  upgrade_step :migrate_data
  upgrade_step :upgrade_params

  Kafo::Helpers.log_and_say :info, "Puppet 3 to 4 upgrade initialization complete, continuing with installation"
end
