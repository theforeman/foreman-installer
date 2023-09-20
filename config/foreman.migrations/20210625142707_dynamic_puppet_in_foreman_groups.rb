if answers['foreman'].is_a?(Hash) && (answers['foreman']['user_groups'] && answers['foreman']['user_groups'].include?('puppet'))
    answers['foreman']['user_groups'].delete('puppet')
end
