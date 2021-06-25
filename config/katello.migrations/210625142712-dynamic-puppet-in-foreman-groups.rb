if answers['foreman'].is_a?(Hash)
  if answers['foreman']['user_groups'] && answers['foreman']['user_groups'].include?('puppet')
    answers['foreman']['user_groups'].delete('puppet')
  end
end
