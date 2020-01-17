# Puppet status codes say 0 for unchanged, 2 for changed succesfully
if [0, 2].include? @kafo.exit_code
  success_message

  if foreman_server?
    server_success_message(@kafo)
    new_install_message(@kafo) if new_install?
  end

  if module_enabled?('katello')
    certs_generate_command_message
  end

  if module_enabled?('katello_devel')
    dev_server_success_message(@kafo)
    dev_new_install_message(@kafo) if new_install?
  end

  # Proxy?
  if module_enabled? 'foreman_proxy'
    proxy_success_message(@kafo)
  end
else
  failure_message
end

log_message(@kafo)
