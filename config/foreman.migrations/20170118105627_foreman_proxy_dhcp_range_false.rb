# false is no longer a valid value, the param should be undef/nil to be disabled
unset_answer('foreman_proxy', 'dhcp_range') if get_answer('foreman_proxy', 'dhcp_range') == false
