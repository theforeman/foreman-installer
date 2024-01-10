if answers['katello'].is_a?(Hash)
  ['manage_repo', 'repo_version', 'repo_gpgcheck', 'repo_gpgkey'].each do |param|
    answers['katello'].delete(param)
  end
end
