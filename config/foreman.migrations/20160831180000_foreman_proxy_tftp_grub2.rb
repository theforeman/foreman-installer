migrate_module('foreman_proxy') do |mod|
  root = mod['tftp_root']
  if (dirs = mod['tftp_dirs'])
    dirs << "#{root}/grub"
    dirs << "#{root}/grub2"
    dirs.uniq!
  end
end
