if answers['foreman_proxy_content'].is_a?(Hash)
  answers['foreman_proxy_content'].delete('reverse_proxy')
end
