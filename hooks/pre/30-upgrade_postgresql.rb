if local_postgresql? && os_needs_postgresql_upgrade?
  postgresql_upgrade(16)
end
