# migrate answers from capsule if exist
answers['foreman_proxy_content'] = answers.delete('capsule') if answers.key?('capsule')
