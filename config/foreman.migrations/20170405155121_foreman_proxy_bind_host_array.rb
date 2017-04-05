if answers['foreman_proxy'] && answers['foreman_proxy']['bind_host'].is_a?(String)
  answers['foreman_proxy']['bind_host'] = [answers['foreman_proxy']['bind_host']]
end
