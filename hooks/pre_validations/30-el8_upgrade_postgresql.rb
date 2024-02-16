if local_postgresql? && os_needs_postgresql_upgrade?
  check_postgresql_storage
end
