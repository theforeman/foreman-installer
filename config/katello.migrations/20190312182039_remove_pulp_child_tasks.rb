# Delete Pulp max tasks per child for Katello
answers['katello'].delete('pulp_max_tasks_per_child') if answers['katello'].is_a?(Hash)
