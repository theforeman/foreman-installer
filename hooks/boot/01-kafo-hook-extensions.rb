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
    Open3.capture3("echo \"#{code}\" | #{bin_path} apply --detailed-exitcodes")
  end

  def fail_and_exit(message, code = 1)
    log_and_say :error, message
    exit code
  end

  def foreman_server?
    module_enabled?('foreman')
  end

  def devel_scenario?
    module_enabled?('katello_devel')
  end

  def local_postgresql?
    param_value('foreman', 'db_manage') || param_value('katello', 'candlepin_manage_db') || devel_scenario?
  end

  def local_redis?
    (foreman_server? && !param_value('foreman', 'jobs_sidekiq_redis_url')) || pulpcore_enabled? || devel_scenario?
  end

  def pulpcore_enabled?
    param_value('foreman_proxy_plugin_pulp', 'pulpcore_enabled')
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
    IO.popen("#{command} 2>&1") do |io|
      while (line = io.gets)
        line.chomp!
        log_and_say(:debug, line, do_say, do_log)
      end
      io.close
      if $CHILD_STATUS.success?
        log_and_say(:debug, "#{command} finished successfully!", do_say, do_log)
      else
        log_and_say(:error, "#{command} failed! Check the output for error!", do_say, do_log)
      end
      $CHILD_STATUS.success?
    end
  end
end

Kafo::HookContext.send(:include, HookContextExtension)
