def check_postgresql_storage
  # Ensure there is at least 1x /var/lib/pgsql free disk space available on the main filesystem
  current_postgres_dir = '/var/lib/pgsql'
  new_postgres_dir = '/var/opt/rh/rh-postgresql12/lib/pgsql'

  begin
    postgres_size = `du --bytes --summarize #{current_postgres_dir}`.split[0].to_i

    if available_space(new_postgres_dir) < postgres_size
      fail_and_exit "The PostgreSQL upgrade requires at least #{(postgres_size / 1024) / 1024} MB of storage to be available at #{new_postgres_dir}."
    end
  rescue StandardError
    fail_and_exit 'Failed to verify available disk space'
  end
end

def available_space(directory = nil)
  directory = '/' if directory.nil?
  mountpoints = facts[:mountpoints]
  until (mountpoint = mountpoints[directory.to_sym])
    directory = File.dirname(directory)
  end
  mountpoint[:available_bytes]
end

if local_postgresql? && el7? && foreman_server? && needs_postgresql_scl_upgrade?
  check_postgresql_storage
end
