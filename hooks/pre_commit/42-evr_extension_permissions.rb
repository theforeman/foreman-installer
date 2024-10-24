# Managed databases will be handled automatically.
return if local_postgresql?

database = param_value('foreman', 'db_database') || 'foreman'
username = param_value('foreman', 'db_username') || 'foreman'
password = param_value('foreman', 'db_password')
host = param_value('foreman', 'db_host')
port = param_value('foreman', 'db_port') || 5432

# If postgres is the owner of the DB, then the permissions will not matter.
return if username == 'postgres'

check_evr_owner_sql = "SELECT CASE" \
                      " WHEN r.rolname = 'postgres' THEN 1" \
                      " ELSE 0" \
                      " END AS evr_owned_by_postgres" \
                      " FROM pg_extension e" \
                      " JOIN pg_roles r ON e.extowner = r.oid" \
                      " WHERE e.extname = 'evr';"

command = "PGPASSWORD='#{password}' psql -U #{username} -h #{host} -p #{port} -d #{database} -t -c \"#{check_evr_owner_sql}\""
logger.debug "Checking if the evr extension is owned by the postgres user via #{command}"
output, _ = execute_command(command, false, true)
unless output.nil?
  if output.strip == '1'
    fail_and_exit("The evr extension is owned by postgres and not the foreman DB owner. Please run the following command to fix it: " \
                  "UPDATE pg_extension SET extowner = (SELECT oid FROM pg_authid WHERE rolname='#{username}');")
  end
end

