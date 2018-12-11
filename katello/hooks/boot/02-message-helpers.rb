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
      say "      Initial credentials are <%= color('#{kafo.param('foreman', 'admin_username').value}', :info) %> / <%= color('#{kafo.param('foreman', 'admin_password').value}', :info) %>"
    end

    def dev_new_install_message(kafo)
      say "      Initial credentials are <%= color('admin', :info) %> / <%= color('#{kafo.param('katello_devel', 'admin_password').value}', :info) %>"
    end

    def proxy_instructions_message(kafo)
      fqdn = if kafo.param('foreman_proxy_certs', 'parent_fqdn')
               kafo.param('foreman_proxy_certs', 'parent_fqdn').value
             else
               `hostname -f`
             end

      certs_tar = kafo.param('foreman_proxy_certs', 'certs_tar').value
      foreman_proxy_fqdn    = kafo.param('foreman_proxy_certs', 'foreman_proxy_fqdn').value
      foreman_oauth_key     = Kafo::Helpers.read_cache_data("oauth_consumer_key")
      foreman_oauth_secret  = Kafo::Helpers.read_cache_data("oauth_consumer_secret")
      org                   = kafo.param('certs', 'org').value

      success_message
      say <<MSG

  To finish the installation, follow these steps:

  If you do not have the smartproxy registered to the Katello instance, then please do the following:

  1. yum -y localinstall http://#{fqdn}/pub/katello-ca-consumer-latest.noarch.rpm
  2. subscription-manager register --org "<%= color('#{org}', :info) %>"

  Once this is completed run the steps below to start the smartproxy installation:

  1. Ensure that the foreman-installer-katello package is installed on the system.
  2. Copy the following file <%= color("#{certs_tar}", :info) %> to the system <%= color("#{foreman_proxy_fqdn}", :info) %> at the following location <%= color("#{File.join('/root', File.basename(certs_tar))}", :info) %>
  scp <%= color("#{certs_tar}", :info) %> root@<%= color("#{foreman_proxy_fqdn}", :info) %>:<%= color("#{File.join('/root', File.basename(certs_tar))}", :info) %>
  3. Run the following commands on the Foreman proxy (possibly with the customized
     parameters, see <%= color("foreman-installer --scenario foreman-proxy-content --help", :info) %> and
     documentation for more info on setting up additional services):

  foreman-installer --scenario foreman-proxy-content\\
                    --certs-tar-file                              "<%= color("#{File.join('/root', File.basename(certs_tar))}", :info) %>"\\
                    --foreman-proxy-content-parent-fqdn           "<%= "#{fqdn}" %>"\\
                    --foreman-proxy-register-in-foreman           "true"\\
                    --foreman-proxy-foreman-base-url              "https://<%= "#{fqdn}" %>"\\
                    --foreman-proxy-trusted-hosts                 "<%= "#{fqdn}" %>"\\
                    --foreman-proxy-trusted-hosts                 "<%= "#{foreman_proxy_fqdn}" %>"\\
                    --foreman-proxy-oauth-consumer-key            "<%= "#{foreman_oauth_key}" %>"\\
                    --foreman-proxy-oauth-consumer-secret         "<%= "#{foreman_oauth_secret}" %>"\\
                    --puppet-server-foreman-url                   "https://<%= "#{fqdn}" %>"
MSG
    end
  end
end
