old_ssl_build_dir = '/root/ssl-build'
new_ssl_build_dir = '/var/lib/foreman-installer/ssl-build'

if module_enabled?('certs')
  if param('certs', 'ssl_build_dir') == old_ssl_build_dir
    if File.exist?(old_ssl_build_dir) && (!File.exist?(new_ssl_build_dir) || Dir.empty?(new_ssl_build_dir))
      FileUtils.mv(old_ssl_build_dir, new_ssl_build_dir)
    end

    kafo.answers['certs']['ssl_build_dir'] = new_ssl_build_dir
  end
end
