# false is no longer a valid value, the param should be undef/nil to be disabled
answers['foreman_proxy']['dhcp_range'] = nil if answers['foreman_proxy'].is_a?(Hash) && answers['foreman_proxy']['dhcp_range'] == false
