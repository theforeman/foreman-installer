require 'open3'

module ServicesHookContextExtension
  ALL_POSSIBLE_SERVICES = [
    '*redis*', # Used by Foreman/Dynflow and Pulpcore
    'apache.service', # Apache on Debian
    'dynflow*',
    'foreman*',
    'httpd.service', # Apache on Red Hat
    'postgresql*', # Used by Foreman/Dynflow and Pulpcore
    'pulpcore*',
    'tomcat.service', # Candlepin
  ].freeze

  def start_services(services)
    raise "Services must be specified" if services.empty?

    logger.debug("Starting services #{services.join(', ')}")
    stdout_and_stderr_str, status = Open3.capture2e('systemctl', 'start', *services)
    fail_and_exit("Failed to start services: #{stdout_and_stderr_str}", status.exitstatus) unless status.success?
  end

  def stop_services(services = ALL_POSSIBLE_SERVICES)
    raise "Can't stop all services" if services.empty?

    logger.debug('Getting running services')
    stdout_str, stderr_str, status = Open3.capture3('systemctl', 'list-units', '--no-legend', '--type=service,socket', '--state=running', *services)
    fail_and_exit("Failed to get running services: #{stderr_str}", status.exitstatus) unless status.success?
    running = stdout_str.lines.map { |line| line.split.first }
    logger.debug("Found running services #{running.inspect}")
    return if running.empty?

    logger.debug("Stopping running services #{running.join(', ')}")
    stdout_and_stderr_str, status = Open3.capture2e('systemctl', 'stop', *running)
    fail_and_exit("Failed to stop running services: #{stdout_and_stderr_str}", status.exitstatus) unless status.success?
  end
end

Kafo::HookContext.send(:include, ServicesHookContextExtension)
