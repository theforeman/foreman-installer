# In Katello 4.15, the 'evr' extension is removed from PostgreSQL and integrated into the Katello database via a migration.
# This hook ensures the 'evr' extension's ownership is transferred to the 'foreman' user so migrations can act on it.

if local_postgresql? && execute("rpm -q postgresql-evr", false, false)
  is_postgresql_active = execute_command("systemctl is-active postgresql", false, true)&.first&.strip == "active"

  # Ensure the PostgreSQL service is running
  unless is_postgresql_active
    logger.debug("Starting postgresql service")
    start_services(['postgresql']) unless app_value(:noop)
  end

  # Update the ownership of the evr extension
  logger.debug("Updating ownership of the evr extension if it is enabled")
  database = param_value('foreman', 'db_database') || 'foreman'
  username = param_value('foreman', 'db_username') || 'foreman'
  sql = "psql -d '#{database}' -c \\\"UPDATE pg_extension SET extowner = (SELECT oid FROM pg_authid WHERE rolname='#{username}') WHERE extname='evr';\\\""
  logger.debug("Executing: #{sql}")
  execute_as!('postgres', sql, false, true) unless app_value(:noop)

  # Stop the PostgreSQL service if it was not running
  unless is_postgresql_active
    logger.debug("Stopping postgresql service")
    stop_services(['postgresql']) unless app_value(:noop)
  end
end
