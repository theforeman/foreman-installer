if answers['foreman'].is_a?(Hash)
  answers['foreman']['user_groups'] = []
elsif answers['foreman']
  answers['foreman'] = {'user_groups': []}
end
