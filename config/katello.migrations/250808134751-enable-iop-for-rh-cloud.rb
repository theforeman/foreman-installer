if answers['foreman::plugin::rh_cloud'].is_a?(Hash) && answers['foreman::plugin::rh_cloud']['enable_iop_advisor_engine']
  answers['iop'] = true
end
