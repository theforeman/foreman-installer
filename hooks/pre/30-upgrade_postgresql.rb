if local_postgresql? && os_needs_postgresql_upgrade?
  if app_value(:noop)
    logger.notice("Would upgrade PostgreSQL from #{current_version} to 16 (noop)")
  else
    postgresql_upgrade(16)
  end
end
