def packages_locked?
  foreman_maintain('packages is-locked --assumeyes')
end

def unlock_packages
  foreman_maintain!('packages unlock --assumeyes')
end

if app_option?(:lock_package_versions)
  # evaluate version locking settings
  cli_param = app_value(:lock_package_versions)
  custom_config_value = get_custom_config(:lock_package_versions)
  lock_versions = cli_param.nil? ? !!custom_config_value : cli_param # rubocop:disable Style/DoubleNegation

  if lock_versions != custom_config_value
    store_custom_config(:lock_package_versions, lock_versions)
    kafo.config.configure_application
  end

  if packages_locked?
    log_and_say :info, "Package versions are locked. Continuing with unlock."
    unlock_packages
  end
elsif get_custom_config(:lock_package_versions)
  # This case can happen if previously packages were locked but this is no
  # longer supported. For example, if foreman-maintain was removed. Clearing
  # this ensures the post hook works properly
  store_custom_config(:lock_package_versions, nil)
  kafo.config.configure_application
  fail_and_exit <<~MESSAGE
  Locking of package versions was requested but foreman-maintain couldn't be used for locking.
  The locking preference was cleared. Rerun the installer with the same arguments to proceed.
  If locking is desired, ensure foreman-maintain can be used and rerun with --lock-package-versions.
  MESSAGE
end
