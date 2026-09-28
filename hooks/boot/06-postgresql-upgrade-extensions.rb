module PostgresqlUpgradeHookContextExtension
  def needs_postgresql_upgrade?(new_version)
    current_version.to_i < new_version.to_i
  rescue Errno::ENOENT
    false
  end

  def current_version
    File.read('/var/lib/pgsql/data/PG_VERSION').chomp
  end

  def os_needs_postgresql_upgrade?
    el9? && needs_postgresql_upgrade?(16)
  end

  def postgresql_upgrade(new_version)
    current = current_version.to_i
    upgrade_versions = postgresql_upgrade_path(current, new_version)
    logger.notice("Performing upgrade of PostgreSQL from #{current} to #{new_version}")

    upgrade_versions.each do |version|
      postgresql_upgrade_step(current, version)
      current = version
    end
  end

  def postgresql_upgrade_path(current_version, new_version)
    current = current_version.to_i
    target = new_version.to_i
    return [] if current >= target

    path = postgresql_upgrade_paths[current]
    upgrade_versions = path&.take_while { |version| version <= target }
    return upgrade_versions if upgrade_versions&.last == target

    fail_and_exit("Cannot upgrade PostgreSQL #{current} to #{target} using supported upgrade steps")
  end

  def postgresql_upgrade_paths
    # EL9 requires PostgreSQL 15 as an intermediate step before 16.
    if el9?
      {
        13 => [15, 16],
        15 => [16],
      }
    else
      {}
    end
  end

  def postgresql_upgrade_step(current_version, new_version)
    logger.notice("Upgrading PostgreSQL from #{current_version} to #{new_version}")

    stop_services

    logger.notice("Upgrading PostgreSQL packages")

    execute!("dnf module switch-to postgresql:#{new_version} -y", false, true)

    server_packages = ['postgresql', 'postgresql-server', 'postgresql-upgrade']
    ['postgresql-contrib', 'postgresql-docs'].each do |extra_package|
      if execute("rpm -q #{extra_package}", false, false)
        server_packages << extra_package
      end
    end

    ensure_packages(server_packages, 'latest')

    logger.notice("Migrating PostgreSQL data")

    # We need to know the collation and ctype of the DB as postgresql-setup --upgrade
    # doesn't detect those on its own: https://issues.redhat.com/browse/RHEL-58410
    # Package selection has replaced the target binaries and the cluster is down.
    # We have to start the cluster in single-user mode with the old postgres binary
    postgres_result = `echo "select datcollate,datctype from pg_database where datname='postgres';" | runuser -l postgres -c '/usr/lib64/pgsql/postgresql-#{current_version}/bin/postgres --single -D /var/lib/pgsql/data postgres'`
    data = {}
    postgres_result.each_line do |line|
      line.match(/dat(collate|ctype)\s+=\s+(\S+)/) do |m|
        data[m[1]] = m[2].delete('"')
      end
    end
    collate = data['collate']
    ctype = data['ctype']

    # puppetlabs-postgresql always sets data_directory in the config
    # see https://github.com/puppetlabs/puppetlabs-postgresql/issues/1576
    # however, one can't use postgresql-setup --upgrade if that value is set
    # see https://bugzilla.redhat.com/show_bug.cgi?id=1935301
    execute!("sed -i '/^data_directory/d' /var/lib/pgsql/data/postgresql.conf", false, true)

    preserve_previous_postgresql_data

    execute_as!('postgres', "PGSETUP_INITDB_OPTIONS=\"--lc-collate=#{collate} --lc-ctype=#{ctype} --locale=#{collate}\" postgresql-setup --upgrade", false, true)

    logger.notice("Analyzing the new PostgreSQL cluster")

    start_services(['postgresql'])

    execute_as!('postgres', 'vacuumdb --all --analyze-in-stages', false, true)

    logger.notice("Upgrade to PostgreSQL #{new_version} completed")
  end

  def preserve_previous_postgresql_data
    previous_data_directory = '/var/lib/pgsql/data-old'
    return unless File.directory?(previous_data_directory)

    previous_version = File.read("#{previous_data_directory}/PG_VERSION").chomp
    preserved_data_directory = "#{previous_data_directory}-#{previous_version}"
    if File.exist?(preserved_data_directory)
      fail_and_exit("Cannot preserve PostgreSQL data: #{preserved_data_directory} already exists")
    end

    execute!("mv #{previous_data_directory} #{preserved_data_directory}", false, true)
  end

  def check_postgresql_storage(new_version = 16)
    # Each pg_upgrade step keeps the previous cluster in data-old and creates a new data directory.
    current_postgres_dir = '/var/lib/pgsql/data'
    new_postgres_dir = '/var/lib/pgsql'

    begin
      current = current_version.to_i
      upgrade_count = postgresql_upgrade_path(current, new_version).length
      postgres_size = `du --bytes --summarize #{current_postgres_dir}`.split[0].to_i
      required_space = postgres_size * upgrade_count

      if available_space(new_postgres_dir) < required_space
        required_megabytes = (required_space / 1024) / 1024
        fail_and_exit "The PostgreSQL upgrade requires at least #{required_megabytes} MB of storage to be available at #{new_postgres_dir}."
      end
    rescue StandardError
      fail_and_exit 'Failed to verify available disk space'
    end
  end
end

Kafo::HookContext.send(:include, PostgresqlUpgradeHookContextExtension)
