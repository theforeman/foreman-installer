migrate_module('foreman') do |mod|
  ['admin_username', 'admin_password', 'admin_first_name', 'admin_last_name', 'admin_email'].each do |var|
    mod.rename_parameter(var, "initial_#{var}")
  end
end
