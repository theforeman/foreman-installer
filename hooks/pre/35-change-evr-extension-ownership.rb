# In Katello 4.16, the 'evr' extension is removed from PostgreSQL and integrated into the Katello database via a migration.
# This hook ensures the 'evr' extension's ownership is transferred to the 'foreman' user so migrations can act on it.

if (local_foreman_db? || devel_scenario?) && execute("rpm -q postgresql-evr", false, false)
  if app_value(:noop)
    logger.debug("Would start postgresql service")
  else
    start_services(['postgresql'])
  end

  database = param_value('foreman', 'db_database') || 'foreman'
  username = param_value('foreman', 'db_username') || 'foreman'

  if local_db_exists?(database)
    sql = "UPDATE pg_extension SET extowner = (SELECT oid FROM pg_authid WHERE rolname='#{username}') WHERE extname='evr'"
    if app_value(:noop)
      logger.debug("Would execute the following SQL statement to update ownership of the evr extension: #{sql}")
    else
      logger.debug("Updating ownership of the evr extension")
      _, success = execute_preformatted_as('postgres', "psql -d #{database} -c \"#{sql}\"", false, true)
      unless success
        fail_and_exit("Failed to update ownership of the evr extension. Please make sure the following sql succeeds before proceeding: #{sql}")
      end
    end
  else
    logger.notice("The Foreman database #{database} does not exist.")
  end
end
