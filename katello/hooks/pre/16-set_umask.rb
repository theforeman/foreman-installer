if File.umask != 0o022
  old = File.umask(0o022)
  logger.info "Set umask to 0022 for installation, former umask was #{old.to_s(8).rjust(4, '0')}"
end
