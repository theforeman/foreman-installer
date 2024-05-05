if answers['foreman'].is_a?(Hash) && answers.dig('foreman', 'db_pool').to_i == 5
  answers['foreman'].delete('db_pool')
end
