if answers['foreman_proxy']
  root = answers['foreman_proxy']['tftp_root']
  if answers['foreman_proxy']['tftp_dirs']
    dirs = answers['foreman_proxy']['tftp_dirs']
    dirs << "#{root}/grub"
    dirs << "#{root}/grub2"
    dirs.uniq!
  end
end
