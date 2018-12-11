# Decouple puppet-foreman_proxy form puppet-capsule

scenario[:log_level] = scenario[:log_level].to_s.upcase

scenario[:order] = [
  "certs",
  "foreman",
  "katello",
  "foreman_proxy",
  "foreman_proxy::plugin::pulp",
  "capsule"
]

# foreman_proxy defaults
answers['foreman_proxy'] = {
  'custom_repo' => true,
  'http' => true,
  'ssl_port' => '9090',
  'templates' => false,
  'ssl_ca' => '/etc/foreman-proxy/ssl_ca.pem',
  'ssl_cert' => '/etc/foreman-proxy/ssl_cert.pem',
  'ssl_key' => '/etc/foreman-proxy/ssl_key.pem',
  'foreman_ssl_ca' => '/etc/foreman-proxy/foreman_ssl_ca.pem',
  'foreman_ssl_cert' => '/etc/foreman-proxy/foreman_ssl_cert.pem',
  'foreman_ssl_key' => '/etc/foreman-proxy/foreman_ssl_key.pem'
}

answers['foreman_proxy::plugin::pulp'] = {
  'enabled' => true,
  'pulpnode_enabled' => false
}

def move(name, default=nil, new_name=nil)
  return unless answers['capsule'].key?(name)
  answers['foreman_proxy'][(new_name || name)] = answers['capsule'].delete(name) { |k| default }
end

# migrate from capsule if exist
if answers['capsule'].is_a? Hash
  move('puppetca', true)
  move('tftp', true)
  move('tftp_syslinux_root')
  move('tftp_syslinux_files')
  move('tftp_root', '/var/lib/tftpboot')
  move('tftp_dirs', ['/var/lib/tftpboot/pxelinux.cfg', '/var/lib/tftpboot/boot'])
  move('tftp_servername')

  move('foreman_proxy_ssl_port', '9090', 'ssl_port')
  move('foreman_proxy_http', true, 'http')
  move('foreman_proxy_http_port', '8000', 'http_port')
end
