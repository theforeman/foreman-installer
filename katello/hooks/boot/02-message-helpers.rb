class Kafo::Helpers
  class << self
    def success_message
      say "  <%= color('Success!', :good) %>"
    end

    def server_success_message(kafo)
      success_message
      say "  * <%= color('Katello', :info) %> is running at <%= color('#{kafo.param('foreman', 'foreman_url').value}', :info) %>"
    end

    def dev_server_success_message(kafo)
      success_message
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
      success_message
      foreman_proxy_url = kafo.param('foreman_proxy', 'registered_proxy_url').value || "https://#{kafo.param('foreman_proxy', 'registered_name').value}:#{kafo.param('foreman_proxy', 'ssl_port').value}"
      say "  * <%= color('Foreman Proxy', :info) %> is running at <%= color('#{foreman_proxy_url}', :info) %>"
    end

    def new_install_message(kafo)
      say "      Initial credentials are <%= color('#{kafo.param('foreman', 'initial_admin_username').value}', :info) %> / <%= color('#{kafo.param('foreman', 'initial_admin_password').value}', :info) %>"
    end

    def dev_new_install_message(kafo)
      say "      Initial credentials are <%= color('admin', :info) %> / <%= color('#{kafo.param('katello_devel', 'admin_password').value}', :info) %>"
    end
  end
end
