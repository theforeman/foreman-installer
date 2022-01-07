if answers['foreman'].is_a?(Hash) && answers['foreman'].key?('jobs_service') && answers['foreman']['jobs_service'].nil?
  answers['foreman'].delete('jobs_service')
end
