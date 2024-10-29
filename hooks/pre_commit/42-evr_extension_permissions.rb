# Managed databases will be handled automatically.
return if local_postgresql?

database = param_value('foreman', 'db_database') || 'foreman'
config = load_db_config(database)

# If postgres is the owner of the DB, then the permissions will not matter.
return if config[:username] == 'postgres'

check_evr_owner_sql = "SELECT CASE" \
                      " WHEN r.rolname = '#{config[:username]}' THEN 0" \
                      " ELSE 1" \
                      " END AS evr_owned_by_postgres" \
                      " FROM pg_extension e" \
                      " JOIN pg_roles r ON e.extowner = r.oid" \
                      " WHERE e.extname = 'evr';"

command = pg_sql_statement(check_evr_owner_sql)
logger.debug "Checking if the evr extension is owned by the postgres user via #{command}"
output, = execute_command(command, false, true, pg_env(config))

case output&.strip
when '0'
  # The evr extension is owned by the foreman DB owner, so we can skip this check.
  return
when '1'
  fail_and_exit("The evr extension is not owned by the #{database} DB owner. Please run the following command to fix it: " \
                "UPDATE pg_extension SET extowner = (SELECT oid FROM pg_authid WHERE rolname='#{config[:username]}') WHERE extname='evr';")
else
  fail_and_exit("Failed to check the ownership of the evr extension.")
end
