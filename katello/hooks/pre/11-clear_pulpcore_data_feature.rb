# See bottom of the script for the command that kicks off the script

def clear_pulpcore_content
  if File.directory?('/var/lib/pulp/docroot')
    FileUtils.rm_rf(Dir.glob("/var/lib/pulp/docroot/*"))
    logger.info 'Pulpcore content successfully removed.'
  else
    logger.warn 'Pulpcore content directory not present at \'/var/lib/pulp/docroot\''
  end
end

clear_pulpcore_content if app_value(:clear_pulpcore_content) && !app_value(:noop) && module_enabled?('foreman_proxy_content')
