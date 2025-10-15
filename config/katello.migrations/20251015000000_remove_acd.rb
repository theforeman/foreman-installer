if answers.key?('foreman::plugin::acd')
  answers.delete('foreman::plugin::acd')
end
if answers.key?('foreman_proxy::plugin::acd')
  answers.delete('foreman_proxy::plugin::acd')
end
