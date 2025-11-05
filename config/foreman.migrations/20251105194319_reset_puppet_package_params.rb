if answers["puppet"].is_a?(Hash)
  puppet = answers["puppet"]

  if puppet.has_key?("server_package") &&
     (puppet["server_package"].nil? || puppet["server_package"].empty?)
    puppet.delete('server_package')
  end

  if puppet.has_key?("package") &&
     (puppet["package"].nil? || puppet["package"].empty?)
    puppet.delete('package')
  end
end
