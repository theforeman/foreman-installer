def postgresql_12_upgrade
  execute('foreman-maintain service start --only=postgresql')
  (_name, _owner, _enconding, collate, ctype, _privileges) = `runuser postgres -c 'psql -lt | grep -E "^\s+postgres"'`.chomp.split('|').map(&:strip)
  execute('foreman-maintain service stop')

  server_packages = ['rh-postgresql12-postgresql-server']
  if execute_command("rpm -q postgresql-contrib", false, false)
    server_packages << 'rh-postgresql12-postgresql-contrib'
  end
  ensure_packages(server_packages, 'installed')

  execute(%(scl enable rh-postgresql12 "PGSETUP_INITDB_OPTIONS='--lc-collate=#{collate} --lc-ctype=#{ctype} --locale=#{collate}' postgresql-setup --upgrade"))
  ensure_packages(['postgresql', 'postgresql-server'], 'absent')
  execute('rm -f /etc/systemd/system/postgresql.service')
  ensure_packages(['rh-postgresql12-syspaths'], 'installed')
end

if local_postgresql? && el7? && foreman_server? && needs_postgresql_scl_upgrade?
  postgresql_12_upgrade
end
