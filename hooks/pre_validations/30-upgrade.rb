if app_value(:upgrade)
  Kafo::MessageHelpers.upgrade_message
  sleep 3
end
