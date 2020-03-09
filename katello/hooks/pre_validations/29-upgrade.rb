if app_value(:upgrade)
  log_and_say(:warn, 'The --upgrade option has been removed. The installer will ensure the system is in the right state. The use of --upgrade is no longer needed.')
end
