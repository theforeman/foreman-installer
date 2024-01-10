if answers['foreman::plugin::tasks'].is_a?(Hash) && !answers['foreman::plugin::tasks'].key?('backup')
  answers['foreman::plugin::tasks']['backup'] = true
end
