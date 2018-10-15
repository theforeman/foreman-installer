mod = answers['foreman']
if mod.is_a?(Hash)
    ['admin_username', 'admin_password', 'admin_first_name', 'admin_last_name', 'admin_email'].each do |var|
      mod["initial_#{var}"] = mod[var] unless mod[var].nil?
    end
end
