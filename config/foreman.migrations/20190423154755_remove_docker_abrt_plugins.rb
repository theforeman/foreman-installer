['foreman::plugin::docker', 'foreman_proxy::plugin::abrt'].each do |plugin|
  answers.delete(plugin) if answers.include?(plugin)
end
