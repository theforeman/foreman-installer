# Puppet status codes say 0 for unchanged, 2 for changed succesfully
if [0, 2].include? @kafo.exit_code
  # Foreman UI?
  if module_enabled? 'foreman'
    Kafo::MessageHelpers.server_success_message(@kafo)
    Kafo::MessageHelpers.new_install_message(@kafo) if new_install?
  end

  if module_enabled?('katello')
    Kafo::MessageHelpers.certs_generate_command_message
  end

  if module_enabled?('katello_devel')
    Kafo::MessageHelpers.dev_server_success_message(@kafo)
    Kafo::MessageHelpers.dev_new_install_message(@kafo) if new_install?
  end

  # Proxy?
  if module_enabled? 'foreman_proxy'
    Kafo::MessageHelpers.proxy_success_message(@kafo)
  end
else
  Kafo::MessageHelpers.failure_message
end

Kafo::MessageHelpers.log_message(@kafo)
