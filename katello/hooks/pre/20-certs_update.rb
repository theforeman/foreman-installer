require 'fileutils'

SSL_BUILD_DIR = param('certs', 'ssl_build_dir').value
CHECK_SCRIPT = `which katello-certs-check`.strip

def error(message)
  logger.error message
  say message
  exit 101
end

def mark_for_update(cert_name, hostname = nil)
  path = File.join(*[SSL_BUILD_DIR, hostname, cert_name].compact)
  puts "Marking certificate #{path} for update"
  if app_value(:noop)
    puts "skipping in noop mode"
  else
    FileUtils.touch("#{path}.update")
  end
end

ca_file   = param('certs', 'server_ca_cert').value
cert_file = param('certs', 'server_cert').value
key_file  = param('certs', 'server_key').value

if app_value('certs_update_server_ca') && !Kafo::Helpers.module_enabled?(@kafo, 'katello')
  error "--certs-update-server-ca needs to be used with katello"
end

if param('foreman_proxy_certs', 'foreman_proxy_fqdn')
  hostname = param('foreman_proxy_certs', 'foreman_proxy_fqdn').value
else
  hostname = param('certs', 'node_fqdn').value
end

if app_value('certs_update_server')
  mark_for_update("#{hostname}-apache", hostname)
  mark_for_update("#{hostname}-foreman-proxy", hostname)
end

if app_value('certs_update_all') || app_value('certs_update_default_ca') || app_value('certs_reset')
  all_cert_names = Dir.glob(File.join(SSL_BUILD_DIR, hostname, '*.noarch.rpm')).map do |rpm|
    File.basename(rpm).sub(/-1\.0-\d+\.noarch\.rpm/, '')
  end.uniq

  all_cert_names.each do |cert_name|
    mark_for_update(cert_name, hostname)
  end
end

if app_value('certs_update_server_ca') || app_value('certs_reset')
  mark_for_update('katello-server-ca')
end

if !app_value('certs_skip_check') &&
       cert_file.to_s != "" &&
       (app_value('certs_update_server_ca') || app_value('certs_update_server'))
  check_cmd = %{#{CHECK_SCRIPT} -c "#{cert_file}" -k "#{key_file}" -b "#{ca_file}"}
  output = `#{check_cmd} 2>&1`
  unless $?.success?
    error "Command '#{check_cmd}' exited with #{$?.exitstatus}:\n #{output}"
  end
end

if app_value('certs_reset') && !app_value(:noop)
  param('certs', 'server_cert').unset_value
  param('certs', 'server_key').unset_value
  param('certs', 'server_ca_cert').unset_value
end
