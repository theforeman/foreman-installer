migrate_module('foreman') do |mod|
  if mod['user_groups'] && mod['user_groups'].include?('puppet')
    mod['user_groups'].delete('puppet')
  end
end
