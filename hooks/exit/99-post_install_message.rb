# Puppet status codes say 0 for unchanged, 2 for changed succesfully
if [0, 2].include? @kafo.exit_code
  success_message

  if foreman_server?
    server_success_message(@kafo)
    new_install_message(@kafo) if new_install?
  end

  if katello_enabled?
    certs_generate_command_message
  end

  if devel_scenario?
    dev_server_success_message(@kafo)
    dev_new_install_message(@kafo) if new_install?
  end

  # Proxy?
  if module_enabled? 'foreman_proxy'
    proxy_success_message(@kafo)
  end

  File.write(success_file, '') if !app_value(:noop) && new_install?
else
  failure_message
end

log_message(@kafo)
