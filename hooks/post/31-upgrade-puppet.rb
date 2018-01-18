if app_value(:upgrade_puppet)
  if [0, 2].include? @kafo.exit_code
    Kafo::Helpers.log_and_say :info, 'Puppet upgrade completed!'
  end
end
