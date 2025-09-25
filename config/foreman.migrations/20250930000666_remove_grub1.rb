if answers['foreman_proxy'].is_a?(Hash)
  root = answers.dig('foreman_proxy', 'tftp_root')
  dirs = answers.dig('foreman_proxy', 'tftp_dirs')

  dirs&.delete_if { |dir| dir == "#{root}/grub" }
end
