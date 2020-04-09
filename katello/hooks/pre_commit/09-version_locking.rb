# evaluate version locking settings
cli_param = app_value(:lock_package_versions)
custom_config_value = get_custom_config(:lock_package_versions)
lock_versions = cli_param.nil? ? !!custom_config_value : cli_param # rubocop:disable Style/DoubleNegation

if lock_versions != custom_config_value
  store_custom_config(:lock_package_versions, lock_versions)
  kafo.config.configure_application
end

if lock_versions && !package_lock_feature?
  fail_and_exit('Locking of package versions was requested but foreman-maintain version installed does not support it')
end

if packages_locked?
  log_and_say :info, "Package versions are locked. Continuing with unlock."
  unlock_packages
end
