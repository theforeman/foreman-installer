# check to see if /dev/log directory exists

if app_value(:disable_system_checks)
  logger.warn 'Skipping system checks.'
  # if dir_present is true then give warning to user and exit otherwise move on with install
elsif File.exist?('/dev/log') == false
  $stderr.puts 'This system is missing the /dev/log socket and will not install correctly, please fix this and then run the installer again.'
  kafo.class.exit(1)
end
