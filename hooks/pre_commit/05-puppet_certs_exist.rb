def error(message)
  say message
  logger.error message
  kafo.class.exit 101
end

def param_value(mod, name)
  param(mod, name).value if param(mod, name)
end

server_crl_path = param_value('foreman', 'server_ssl_crl')
puppet_server_implementation = param_value('puppet', 'server_implementation')
puppet_passenger = param_value('puppet', 'server_passenger')
cert_dir = param_value('puppet', 'server_ssl_dir')
puppet_ca_cert = File.join(cert_dir, 'ca/ca_crt.pem')
puppet_enabled = kafo.module('puppet').enabled?

client_message = "- is Puppet already installed without Puppet CA? You can remove the existing certificates with 'rm -rf #{cert_dir}' to get Puppet CA properly configured."

if cert_dir && File.directory?(cert_dir)
  if !server_crl_path.empty? && !File.exists?(server_crl_path)
    error "The file #{server_crl_path} does not exist.\n #{client_message}\n - if you set custom revocation list (--foreman-server-ssl-crl) make sure the file exists."
  end
  if puppet_enabled && puppet_passenger && puppet_server_implementation == 'master' && !File.exists?(puppet_ca_cert)
    error "The file #{puppet_ca_cert} does not exist.\n #{client_message}\n - if you use custom Puppet SSL directory (--puppet-server-ssl-dir) make sure the directory exists and contain the CA certificate.\n   Also make sure --enable-puppet, --puppet-server-passenger and --puppet-server-implementation are set properly"
  end
end
