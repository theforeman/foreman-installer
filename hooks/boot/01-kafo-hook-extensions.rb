require 'English'
require 'open3'

module HookContextExtension
  # FIXME: remove when #23332 is released
  def param_value(mod, name)
    param(mod, name).value if param(mod, name)
  end

  def success_file
    File.join(File.dirname(kafo.config.config_file), '.installed')
  end

  def new_install?
    !File.exist?(success_file)
  end

  def ensure_packages(packages, state = 'installed')
    return if packages.empty?

    code = "package { ['#{packages.join('\', \'')}']: ensure => #{state} }"
    logger.info("Ensuring #{packages.join(', ')} to package state #{state}")
    stdout, stderr, status = apply_puppet_code(code)

    unless [0, 2].include?(status.exitstatus)
      log_and_say(:error, "Failed to ensure #{packages.join(', ')} #{(packages.length == 1) ? 'is' : 'are'} #{state}")
      log_and_say(:error, stderr.strip) if stderr && stderr.strip
      logger.debug(stdout.strip) if stdout && stdout.strip
      logger.debug("Exit status is #{status.exitstatus.inspect}")
      exit(1)
    end
  end

  def apply_puppet_code(code)
    bin_path = Kafo::PuppetCommand.search_puppet_path('puppet')
    Open3.capture3(*Kafo::PuppetCommand.format_command("echo \"#{code}\" | #{bin_path} apply --detailed-exitcodes"))
  end

  def fail_and_exit(message, code = 1)
    log_and_say :error, message
    exit code
  end

  def foreman_server?
    module_enabled?('foreman')
  end

  def katello_enabled?
    module_enabled?('katello')
  end

  def katello_present?
    module_present?('katello')
  end

  def devel_scenario?
    module_enabled?('katello_devel')
  end

  def local_foreman_db?
    foreman_server? && param_value('foreman', 'db_manage')
  end

  def local_candlepin_db?
    candlepin_enabled? && param_value('katello', 'candlepin_manage_db')
  end

  def local_postgresql?
    local_foreman_db? || local_candlepin_db? || devel_scenario?
  end

  def local_redis?
    (foreman_server? && !param_value('foreman', 'jobs_sidekiq_redis_url')) || pulpcore_enabled? || devel_scenario?
  end

  def candlepin_enabled?
    katello_enabled?
  end

  def pulp_enabled?
    module_enabled?('foreman_proxy_plugin_pulp') && (param_value('foreman_proxy_plugin_pulp', 'pulpnode_enabled') || param_value('foreman_proxy_plugin_pulp', 'enabled'))
  end

  def pulp_present?
    module_present?('foreman_proxy_plugin_pulp')
  end

  def pulpcore_enabled?
    module_enabled?('foreman_proxy_plugin_pulp') && param_value('foreman_proxy_plugin_pulp', 'pulpcore_enabled')
  end

  def needs_postgresql_scl_upgrade?
    !File.exist?('/var/opt/rh/rh-postgresql12/lib/pgsql/data') && File.exist?('/var/lib/pgsql/data')
  end

  def el7?
    facts[:os][:release][:major] == '7' && facts[:os][:family] == 'RedHat'
  end

  def log_and_say(level, message, do_say = true, do_log = true)
    style = case level
            when :error
              'bad'
            when :debug
              'yellow'
            when :warn
              'yellow'
            else
              level
            end

    say HighLine.color(message, style.to_sym) if do_say
    Kafo::KafoConfigure.logger.send(level, message) if do_log
  end

  def execute(commands, do_say = true, do_log = true)
    commands = commands.is_a?(Array) ? commands : [commands]
    results = []

    commands.each do |command|
      results << execute_command(command, do_say, do_log)
    end

    if results.include? false
      exit 1
    end
  end

  def execute_command(command, do_say, do_log)
    log_and_say(:debug, "Executing: #{command}", do_say, do_log)

    begin
      stdout_stderr, status = Open3.capture2e(*Kafo::PuppetCommand.format_command(command))
    rescue Errno::ENOENT
      log_and_say(:error, "Command #{command} not found", do_say, do_log)
      return false
    end

    stdout_stderr.lines.map(&:chomp).each do |line|
      log_and_say(:debug, line, do_say, do_log)
    end

    if status.success?
      log_and_say(:debug, "#{command} finished successfully!", do_say, do_log)
    else
      log_and_say(:error, "#{command} failed! Check the output for error!", do_say, do_log)
    end
    status.success?
  end
end

def remote_host?(hostname)
  !['localhost', '127.0.0.1', `hostname`.strip].include?(hostname)
end

def load_mongo_config
  seeds = param_value('katello', 'pulp_db_seeds')
  seed = seeds.split(',').first
  host, port = seed.split(':') if seed
  {
    host: host || 'localhost',
    port: port || '27017',
    database: param_value('katello', 'pulp_db_name') || 'pulp_database',
    username: param_value('katello', 'pulp_db_username'),
    password: param_value('katello', 'pulp_db_password'),
    ssl: param_value('katello', 'pulp_db_ssl') || false,
    ca_path: param_value('katello', 'pulp_db_ca_path'),
    ssl_certfile: param_value('katello', 'pulp_db_ssl_certfile'),
  }
end

Kafo::HookContext.send(:include, HookContextExtension)
