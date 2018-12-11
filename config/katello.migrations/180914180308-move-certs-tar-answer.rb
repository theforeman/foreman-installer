if answers['foreman_proxy_content'].is_a?(Hash) && answers['foreman_proxy_content']['certs_tar']
  answer = answers['foreman_proxy_content'].delete('certs_tar')
  if answers['certs'].is_a?(Hash)
    answers['certs']['tar_file'] = answer
  elsif answers['certs']
    answers['certs'] = {'tar_file' => answer}
  end
end
