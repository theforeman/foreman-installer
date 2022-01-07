# Delete Pulp max tasks per child for foreman-proxy-content
answers['foreman_proxy_content'].delete('pulp_max_tasks_per_child') if answers['foreman_proxy_content'].is_a?(Hash)
