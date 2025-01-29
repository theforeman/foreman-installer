module KatelloCertsMessageHookContextExtension
  def main_instance_name
    'Katello'
  end

  def proxy_name
    'Smart Proxy'
  end

  def installer_package
    'foreman-installer-katello'
  end

  def scenario_name
    'foreman-proxy-content'
  end

  def installer_command
    'foreman-installer'
  end

  def proxy_instructions_message(kafo)
    fqdn = if kafo.param('foreman_proxy_certs', 'parent_fqdn')
             kafo.param('foreman_proxy_certs', 'parent_fqdn').value
           else
             `hostname -f`
           end

    certs_tar = kafo.param('foreman_proxy_certs', 'certs_tar').value
    foreman_proxy_fqdn = kafo.param('foreman_proxy_certs', 'foreman_proxy_fqdn').value
    foreman_oauth_key = read_cache_data("oauth_consumer_key")
    foreman_oauth_secret = read_cache_data("oauth_consumer_secret")

    certs_tar_file = File.join('/root', File.basename(certs_tar))
    foreman_url = "https://#{fqdn}"

    say <<MSG
  <%= color('Success!', :good) %>

  To finish the installation, follow these steps:

  1. Register the #{proxy_name} to the #{main_instance_name} instance.
  2. Ensure that the #{installer_package} package is installed on the system.
  3. Copy the following file <%= color("#{certs_tar}", :info) %> to the system <%= color("#{foreman_proxy_fqdn}", :info) %> at the following location <%= color("#{certs_tar_file}", :info) %>
  scp <%= color("#{certs_tar}", :info) %> root@<%= color("#{foreman_proxy_fqdn}", :info) %>:<%= color("#{certs_tar_file}", :info) %>
  4. Run the following commands on the #{proxy_name} (possibly with the customized
     parameters, see <%= color("#{installer_command} --scenario #{scenario_name} --help", :info) %> and
     documentation for more info on setting up additional services):

  #{installer_command}\\
                    --scenario #{scenario_name}\\
                    --certs-tar-file                              "<%= color("#{certs_tar_file}", :info) %>"\\
                    --foreman-proxy-register-in-foreman           "true"\\
                    --foreman-proxy-foreman-base-url              "#{foreman_url}"\\
                    --foreman-proxy-trusted-hosts                 "#{fqdn}"\\
                    --foreman-proxy-trusted-hosts                 "#{foreman_proxy_fqdn}"\\
                    --foreman-proxy-oauth-consumer-key            "#{foreman_oauth_key}"\\
                    --foreman-proxy-oauth-consumer-secret         "#{foreman_oauth_secret}"
MSG
  end
end

Kafo::HookContext.send(:include, KatelloCertsMessageHookContextExtension)
