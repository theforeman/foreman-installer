# 18ac4a1b2e667ad24a7db418c27af8e48f559905
# The Ansible repo is no longer a thing for Debian
if answers['foreman_proxy::plugin::ansible'].is_a?(Hash) && facts[:os][:family] == 'Debian'
  answers['foreman_proxy::plugin::ansible'].delete('manage_runner_repo')
end
