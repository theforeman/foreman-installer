# Working around https://tickets.puppetlabs.com/browse/PUP-10548
if facts.dig(:os, :selinux, :enabled)
  packages = []

  packages << 'foreman-selinux' if foreman_server?
  packages << 'katello-selinux' if katello_enabled?
  packages << 'candlepin-selinux' if katello_enabled?
  packages << 'pulpcore-selinux' if pulpcore_enabled?

  ensure_packages(packages, 'installed')
end
