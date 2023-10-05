if answers['foreman'].is_a?(Hash) && answers.dig('foreman', 'rails_cache_store', 'type') == 'file'
  answers['foreman']['rails_cache_store'] = { 'type' => 'redis' }
end
