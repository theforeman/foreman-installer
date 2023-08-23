module MessageHookContextExtension
  def success_message
    say "  <%= color('Success!', :good) %>"
  end

  def server_success_message(kafo)
    say "  * <%= color('Foreman', :info) %> is running at <%= color('#{kafo.param('foreman', 'foreman_url').value}', :info) %>"
  end

  def dev_server_success_message(kafo)
    say "  * To run the <%= color('Katello', :info) %> dev server log in using SSH"
    say "  * Run `cd foreman && bundle exec foreman start`"
    say "  * The server is running at <%= color('https://#{`hostname -f`}', :info) %>"
    if kafo.param('katello_devel', 'webpack_dev_server').value
      say "  * On Firefox you need to accept the certificate at <%= color('https://#{`hostname -f`}:3808', :info) %>"
    end
  end

  def certs_generate_command_message
    say <<MSG
  * To install an additional Foreman proxy on separate machine continue by running:

      foreman-proxy-certs-generate --foreman-proxy-fqdn "<%= color('$FOREMAN_PROXY', :info) %>" --certs-tar "<%= color('/root/$FOREMAN_PROXY-certs.tar', :info) %>"
MSG
  end

  def proxy_success_message(kafo)
    foreman_proxy_url = kafo.param('foreman_proxy', 'registered_proxy_url').value || "https://#{kafo.param('foreman_proxy', 'registered_name').value}:#{kafo.param('foreman_proxy', 'ssl_port').value}"
    say "  * <%= color('Foreman Proxy', :info) %> is running at <%= color('#{foreman_proxy_url}', :info) %>"
  end

  def new_install_message(kafo)
    say "      Initial credentials are <%= color('#{kafo.param('foreman', 'initial_admin_username').value}', :info) %> / <%= color('#{kafo.param('foreman', 'initial_admin_password').value}', :info) %>"
  end

  def dev_new_install_message(kafo)
    say "      Initial credentials are <%= color('admin', :info) %> / <%= color('#{kafo.param('katello_devel', 'admin_password').value}', :info) %>"
  end

  def failure_message
    message = 'There were errors detected during installation.'

    if puppet_report&.failed_resources&.any?
      say "\n"

      puppet_report.failed_resources.each_with_index do |failed_resource, index|
        say "Error #{index + 1}: #{failed_resource} failed. Logs:"
        failed_resource.log_messages_by_source.each do |source, log_messages|
          say "  #{source}"
          log_messages.each do |log_message|
            say "    #{log_message}"
          end
        end
      end

      message = if puppet_report.failed_resources.length == 1
                  '1 error was detected during installation.'
                else
                  "#{puppet_report.failed_resources.length} errors were detected."
                end
    end

    say "\n<%= color('#{message}', :bad) %>"
    say "Please address the errors and re-run the installer to ensure the system is properly configured."
    say "Failing to do so is likely to result in broken functionality."
  end

  def log_message(kafo)
    say "\nThe full log is at <%= color('#{kafo.config.log_file}', :info) %>"
  end
end

Kafo::HookContext.send(:include, MessageHookContextExtension)
