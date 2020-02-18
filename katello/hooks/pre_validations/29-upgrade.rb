if app_value(:upgrade)
  fail_and_exit 'The --upgrade option has been removed. The installer will ensure the system is in the right state. The use of --upgrade is no longer needed.'
end
