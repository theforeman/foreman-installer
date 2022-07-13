puppet_ca_enabled = module_enabled?('foreman_proxy') && param_value('foreman_proxy', 'puppetca')
server_crl_path = param_value('foreman', 'server_ssl_crl')
cert_dir = param_value('foreman_proxy', 'ssldir')
key_path = param_value('foreman_proxy', 'puppet_ssl_key')
puppet_ca_cert = param_value('foreman_proxy', 'puppet_ssl_ca')

client_message = "- is Puppet already installed without Puppet CA? You can remove the existing certificates with 'rm -rf #{cert_dir}' to get Puppet CA properly configured."

if puppet_ca_enabled && key_path && File.exist?(key_path) && !kafo.skip_checks_i_know_better?
  if !puppet_ca_cert.empty? && !File.exist?(puppet_ca_cert)
    fail_and_exit("The file #{puppet_ca_cert} does not exist.\n #{client_message}\n" \
    " - if you use custom Puppet SSL directory (--foreman-proxy-ssldir) make sure the directory exists and contain the CA certificate.\n", 101)
  end
  if server_crl_path.is_a?(String) && !server_crl_path.empty? && !File.exist?(server_crl_path)
    fail_and_exit("The file #{server_crl_path} does not exist.\n #{client_message}\n - if you set custom revocation list (--foreman-server-ssl-crl) make sure the file exists.", 101)
  end
end
