if module_enabled?('certs')
  if app_value(:certs_update_server_ca) && !module_enabled?('katello')
    fail_and_exit("--certs-update-server-ca needs to be used with katello", 101)
  end

  if app_value(:certs_reset)
    param('certs', 'server_cert').unset_value
    param('certs', 'server_key').unset_value
    param('certs', 'server_ca_cert').unset_value
  end

  ca_file   = param('certs', 'server_ca_cert').value
  cert_file = param('certs', 'server_cert').value
  key_file  = param('certs', 'server_key').value

  if !app_value(:certs_skip_check) && !cert_file.to_s.empty? &&
     (app_value(:certs_update_server_ca) || app_value(:certs_update_server))
    execute_command(%(katello-certs-check -c "#{cert_file}" -k "#{key_file}" -b "#{ca_file}"))
  end
end
