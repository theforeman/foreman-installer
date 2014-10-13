# Puppet status codes say 0 for unchanged, 2 for changed succesfully
if [0,2].include? @kafo.exit_code
  say "  <%= color('Success!', :good) %>"

  # Foreman UI?
  if @kafo.config.module_enabled? 'foreman'
    say "  * <%= color('Foreman', :info) %> is running at <%= color('#{param('foreman','foreman_url').value}', :info) %>"
    say "      Initial credentials are <%= color('#{param('foreman', 'admin_username').value}', :info) %> / <%= color('#{param('foreman', 'admin_password').value}', :info) %>" if param('foreman','authentication').value == true
  end

  # Proxy?
  if @kafo.config.module_enabled? 'foreman_proxy'
    say "  * <%= color('Foreman Proxy', :info) %> is running at <%= color('#{param('foreman_proxy','registered_proxy_url').value}', :info) %>"
  end

  # Puppetmaster?
  if ( @kafo.config.module_enabled?('puppet') && ( param('puppet','server').value != false ) )
    say "  * <%= color('Puppetmaster', :info) %> is running at <%= color('port #{param('puppet','server_port').value}', :info) %>"
  end
else
  say "  <%= color('Something went wrong!', :bad) %> Check the log for ERROR-level output"
end

# This is always useful, success or fail
log = app_value(:log_dir) + '/' + app_value(:log_name)
say "  The full log is at <%= color('#{log}', :info) %>"
