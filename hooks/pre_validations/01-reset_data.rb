if app_value(:reset_data) && !app_value(:noop)
  response = ask('Are you sure you want to continue? This will drop the databases, reset all configurations that you have made and bring all application data back to a fresh install. [y/n]')
  if response.downcase != 'y'
    $stderr.puts '** cancelled **'
    exit(1)
  end
end
