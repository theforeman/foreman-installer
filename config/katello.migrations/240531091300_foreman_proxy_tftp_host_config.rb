if answers['foreman_proxy'].is_a?(Hash)
  root = answers['foreman_proxy']['tftp_root']
  if root && answers['foreman_proxy']['tftp_dirs']
    dirs = answers['foreman_proxy']['tftp_dirs']
    dirs << "#{root}/bootloader-universe"
    dirs << "#{root}/bootloader-universe/pxegrub2"
    dirs << "#{root}/host-config"
    dirs.uniq!
  end
end
