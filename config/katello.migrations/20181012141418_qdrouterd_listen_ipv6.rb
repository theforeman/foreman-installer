mod = answers['foreman_proxy_content']
if mod.is_a?(Hash)
  ['qpid_router_agent_addr', 'qpid_router_hub_addr'].each do |var|
    mod.delete(var) if mod[var] == '0.0.0.0'
  end
end
