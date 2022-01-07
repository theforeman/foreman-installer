# False is not a valid value for DHCP range
answers['foreman_proxy'].delete('dhcp_range') if answers['foreman_proxy'].is_a?(Hash) && answers['foreman_proxy']['dhcp_range'] == false
