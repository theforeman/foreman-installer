class Kafo::Helpers
  class << self
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
      org                   = kafo.param('certs', 'org').value.tr(' ', '_')

      certs_tar_file = File.join('/root', File.basename(certs_tar))
      foreman_url = "https://#{fqdn}"

      say <<MSG
  <%= color('Success!', :good) %>

  To finish the installation, follow these steps:

  If you do not have the smartproxy registered to the Katello instance, then please do the following:

  1. yum -y localinstall http://#{fqdn}/pub/katello-ca-consumer-latest.noarch.rpm
  2. subscription-manager register --org "<%= color('#{org}', :info) %>"

  Once this is completed run the steps below to start the smartproxy installation:

  1. Ensure that the foreman-installer-katello package is installed on the system.
  2. Copy the following file <%= color("#{certs_tar}", :info) %> to the system <%= color("#{foreman_proxy_fqdn}", :info) %> at the following location <%= color("#{certs_tar_file}", :info) %>
  scp <%= color("#{certs_tar}", :info) %> root@<%= color("#{foreman_proxy_fqdn}", :info) %>:<%= color("#{certs_tar_file}", :info) %>
  3. Run the following commands on the Foreman proxy (possibly with the customized
     parameters, see <%= color("foreman-installer --scenario foreman-proxy-content --help", :info) %> and
     documentation for more info on setting up additional services):

  foreman-installer --scenario foreman-proxy-content\\
                    --certs-tar-file                              "<%= color("#{certs_tar_file}", :info) %>"\\
                    --foreman-proxy-content-parent-fqdn           "#{fqdn}"\\
                    --foreman-proxy-register-in-foreman           "true"\\
                    --foreman-proxy-foreman-base-url              "#{foreman_url}"\\
                    --foreman-proxy-trusted-hosts                 "#{fqdn}"\\
                    --foreman-proxy-trusted-hosts                 "#{foreman_proxy_fqdn}"\\
                    --foreman-proxy-oauth-consumer-key            "#{foreman_oauth_key}"\\
                    --foreman-proxy-oauth-consumer-secret         "#{foreman_oauth_secret}"\\
                    --puppet-server-foreman-url                   "#{foreman_url}"
MSG
    end
  end
end
