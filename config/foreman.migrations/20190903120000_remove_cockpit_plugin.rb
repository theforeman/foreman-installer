['foreman::plugin::cockpit'].each do |plugin|
  answers.delete(plugin) if answers.include?(plugin)
end
