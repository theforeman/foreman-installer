# Puppet status codes say 0 for unchanged, 2 for changed succesfully
if [0,2].include? @kafo.exit_code
  say "  <%= color('Success!', :good) %>"
else
  say "  <%= color('Something went wrong!', :bad) %> Check the log for ERROR-level output"
end

# Foreman UI?
if module_enabled? 'foreman'
  say "  * <%= color('Foreman', :info) %> is running at <%= color('#{param('foreman','foreman_url').value}', :info) %>"
  say "      Initial credentials are <%= color('#{param('foreman', 'initial_admin_username').value}', :info) %> / <%= color('#{param('foreman', 'initial_admin_password').value}', :info) %>"
end

# Proxy?
if module_enabled? 'foreman_proxy'
  proxy_url = param('foreman_proxy','registered_proxy_url').value
  if proxy_url.nil? || proxy_url.empty?
    proxy_url = "https://#{param('foreman_proxy','registered_name').value}:#{param('foreman_proxy','ssl_port').value}"
  end
  say "  * <%= color('Foreman Proxy', :info) %> is running at <%= color('#{proxy_url}', :info) %>"
end

# Puppetmaster?
if ( module_enabled?('puppet') && ( param('puppet','server').value != false ) )
  say "  * <%= color('Puppetmaster', :info) %> is running at <%= color('port #{param('puppet','server_port').value}', :info) %>"
end

# This is always useful, success or fail
log = app_value(:log_dir) + '/' + app_value(:log_name)
say "  The full log is at <%= color('#{log}', :info) %>"
