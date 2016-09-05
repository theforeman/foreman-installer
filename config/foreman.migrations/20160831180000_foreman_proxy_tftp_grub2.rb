root = answers['foreman_proxy']['tftp_root']
dirs = answers['foreman_proxy']['tftp_dirs']
dirs << "#{root}/grub"
dirs << "#{root}/grub2"
dirs.uniq!
