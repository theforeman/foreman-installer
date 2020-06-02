require 'fileutils'
require 'English'

if module_enabled?('certs')
  SSL_BUILD_DIR = param('certs', 'ssl_build_dir').value

  def mark_for_update(cert_name, hostname = nil)
    path = File.join(*[SSL_BUILD_DIR, hostname, cert_name].compact)
    if app_value(:noop)
      puts "Marking certificate #{path} for update (noop)"
    else
      puts "Marking certificate #{path} for update"
      FileUtils.touch("#{path}.update")
    end
  end

  if param('foreman_proxy_certs', 'foreman_proxy_fqdn')
    hostname = param('foreman_proxy_certs', 'foreman_proxy_fqdn').value
  else
    hostname = param('certs', 'node_fqdn').value
  end

  if app_value(:certs_update_server)
    mark_for_update("#{hostname}-apache", hostname)
    mark_for_update("#{hostname}-foreman-proxy", hostname)
  end

  if app_value(:certs_update_all) || app_value(:certs_update_default_ca) || app_value(:certs_reset)
    all_cert_names = Dir.glob(File.join(SSL_BUILD_DIR, hostname, '*.noarch.rpm')).map do |rpm|
      File.basename(rpm).sub(/-1\.0-\d+\.noarch\.rpm/, '')
    end.uniq

    all_cert_names.each do |cert_name|
      mark_for_update(cert_name, hostname)
    end
  end

  if app_value(:certs_update_server_ca) || app_value(:certs_reset)
    mark_for_update('katello-server-ca')
  end
end
