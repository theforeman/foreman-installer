scenario[:order] = [
  "certs",
  "foreman_proxy",
  "foreman_proxy::plugin::pulp",
  "foreman_proxy_content"
]

# migrate answers from capsule if exist
answers['foreman_proxy_content'] = answers.delete('capsule') if answers.key?('capsule')
