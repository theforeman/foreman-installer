certs_tar = param('foreman_proxy_certs', 'certs_tar')

if certs_tar.value
  certs_tar.value = File.expand_path(certs_tar.value)
end
