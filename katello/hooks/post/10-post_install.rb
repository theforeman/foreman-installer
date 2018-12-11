def success_file
  File.join(File.dirname(Kafo::KafoConfigure.config_file), '.installed')
end

def new_install?
  !File.exist?(success_file)
end

def proxy?
  system("rpm -q foreman-proxy-content > /dev/null") && !system("rpm -q katello > /dev/null")
end

if [0, 2].include?(@kafo.exit_code)
  if !app_value(:upgrade)
    if Kafo::Helpers.module_enabled?(@kafo, 'katello')
      Kafo::Helpers.server_success_message(@kafo)
      Kafo::Helpers.new_install_message(@kafo) if @kafo.param('foreman', 'authentication').value == true && new_install?
      Kafo::Helpers.certs_generate_command_message
    elsif Kafo::Helpers.module_enabled?(@kafo, 'katello_devel')
      Kafo::Helpers.dev_server_success_message(@kafo)
      Kafo::Helpers.dev_new_install_message(@kafo) if new_install?
    end

    Kafo::Helpers.proxy_instructions_message(@kafo) if Kafo::Helpers.module_enabled?(@kafo, 'foreman_proxy_certs')
    Kafo::Helpers.proxy_success_message(@kafo) if proxy?
  end

  File.open(success_file, 'w') {} unless app_value(:noop) # Used to indicate that we had a successful install
  exit_code = 0

else

  say "  <%= color('Something went wrong!', :bad) %> Check the log for ERROR-level output"
  exit_code = @kafo.exit_code

end

# This is always useful, success or fail
log = @kafo.config.app[:log_dir] + '/' + @kafo.config.app[:log_name]
say "  The full log is at <%= color('#{log}', :info) %>"
