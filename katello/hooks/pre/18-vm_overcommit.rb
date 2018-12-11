# Check to see if vm.overcommit is enabled and if so exit but also give the user an option to disable the check with the --disable-system-checks flag
if app_value(:disable_system_checks)
  logger.warn 'Skipping system checks.'
else
  # Grab the current status of vm.overcommit from sysctl
  overcommit_check = `sysctl -n vm.overcommit_memory`.to_i
  if overcommit_check > 0
    $stderr.puts 'This system has the vm.overcommit.memory flag enabled in sysctl. Please set this to 0 and then run the installer again.'
    kafo.class.exit(1)
  end
end
