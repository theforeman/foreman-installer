# Add options around regenerating certificates
if module_present?('certs')
  app_option(
    '--certs-update-server',
    :flag,
    "This option will enforce an update of the HTTPS certificates",
    :default => false
  )
  app_option(
    '--certs-update-server-ca',
    :flag,
    "This option will enforce an update of the CA used for HTTPS certificates.",
    :default => false
  )
  app_option(
    '--certs-update-all',
    :flag,
    "This option will enforce an update of all the certificates for given host",
    :default => false
  )
  app_option(
    '--certs-reset',
    :flag,
    "This option will reset any custom certificates and use the self-signed CA " \
    "instead. Note that any clients will need to be updated with the latest " \
    "katello-ca-consumer RPM, and any external proxies will need to have the " \
    "certs updated by generating a new certs tarball.",
    :default => false
  )
  app_option(
    '--certs-skip-check',
    :flag,
    "This option will cause skipping the certificates sanity check. Use with caution",
    :default => false
  )
end
