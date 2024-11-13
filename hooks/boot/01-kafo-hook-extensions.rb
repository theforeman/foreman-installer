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

  def local_pulpcore_db?
    pulpcore_enabled? && param_value('foreman_proxy_content', 'pulpcore_manage_postgresql')
  end

  def local_postgresql?
    local_foreman_db? || local_candlepin_db? || local_pulpcore_db? || devel_scenario?
  end

  def local_redis?
    (foreman_server? && !param_value('foreman', 'jobs_sidekiq_redis_url')) || pulpcore_enabled? || devel_scenario?
  end

  def candlepin_enabled?
    katello_enabled?
  end

  def pulpcore_enabled?
    module_enabled?('foreman_proxy_content')
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

  def execute!(command, do_say = true, do_log = true, extra_env = {})
    stdout_stderr, status = execute_command(command, do_say, do_log, extra_env)

    if stdout_stderr.nil?
      log_and_say(:error, "Command #{command} not found", do_say, do_log)
      exit 1
    end

    unless status
      log_and_say(:error, "#{command} failed! Check the output for error!", do_say, do_log)
      exit 1
    end
  end

  def execute_as!(user, command, do_say = true, do_log = true, extra_env = {})
    runuser_command = "runuser -l #{user} -c '#{command}'"
    execute!(runuser_command, do_say, do_log, extra_env)
  end

  def execute(command, do_say, do_log, extra_env = {})
    _stdout_stderr, status = execute_command(command, do_say, do_log, extra_env)
    status
  end

  def execute_command(command, do_say, do_log, extra_env = {})
    log_and_say(:debug, "Executing: #{command}", do_say, do_log)

    begin
      stdout_stderr, status = Open3.capture2e(*Kafo::PuppetCommand.format_command(command, extra_env))
    rescue Errno::ENOENT
      return [nil, false]
    end

    stdout_stderr.lines.map(&:chomp).each do |line|
      log_and_say(:debug, line, do_say, do_log)
    end

    [stdout_stderr, status.success?]
  end

  def remote_host?(hostname)
    !['localhost', '127.0.0.1', `hostname`.strip].include?(hostname)
  end

  def el8?
    facts[:os][:release][:major] == '8' && facts[:os][:family] == 'RedHat'
  end

  def available_space(directory = nil)
    directory = '/' if directory.nil?
    mountpoints = facts[:mountpoints]
    until (mountpoint = mountpoints[directory.to_sym])
      directory = File.dirname(directory)
    end
    mountpoint[:available_bytes]
  end

  def parse_java_version(output)
    output&.match(/version "(?<version>\d+\.\d+)\.\d+/) do |java_match|
      return unless (version = java_match[:version])

      version = version.delete_prefix('1.') if version.start_with?('1.')

      yield version.to_i
    end
  end
end

Kafo::HookContext.send(:include, HookContextExtension)
