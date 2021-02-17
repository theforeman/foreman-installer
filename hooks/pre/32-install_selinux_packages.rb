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

  if katello_enabled? && el8?
    # candlepin-selinux pulls in candlepin which requires pki-core
    execute!('dnf module enable pki-core --assumeyes', false, true)
  end

  ensure_packages(packages, 'installed')
end
