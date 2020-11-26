# Working around https://tickets.puppetlabs.com/browse/PUP-10548
if facts.dig(:os, :selinux, :enabled)
  packages = []

  if el7?
    packages << 'rh-postgresql12-postgresql-server' if local_postgresql?
    packages << 'rh-redis5-redis' if local_redis?
  end

  packages << 'foreman-selinux' if foreman_server?
  packages << 'katello-selinux' if katello_enabled?
  packages << 'candlepin-selinux' if katello_enabled?
  packages << 'pulpcore-selinux' if pulpcore_enabled?
  packages << 'crane-selinux' if pulp_enabled?

  if ensure_packages(packages, 'installed')
    # systemd 245+ reloads SELinux contexts on daemon-reload
    # https://github.com/systemd/systemd/commit/a9dfac21ec850eb5dcaf1ae9ef729389e4c12802
    # EL8 is 239, EL7 is 219
    `systemctl daemon-reexec`
  end
end
