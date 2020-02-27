# evaluate version locking settings
cli_param = app_value(:lock_package_versions)
custom_config_value = get_custom_config(:lock_package_versions)
lock_versions = cli_param.nil? ? !!custom_config_value : cli_param # rubocop:disable Style/DoubleNegation

if lock_versions != custom_config_value
  store_custom_config(:lock_package_versions, lock_versions)
  kafo.config.configure_application
end

if lock_versions
  unless system('command -v foreman-maintain > /dev/null')
    fail_and_exit('Locking of package versions was requested but foreman-maintain is not installed')
  end
  unless system('foreman-maintain packages -h > /dev/null 2>&1')
    fail_and_exit('Locking of package versions was requested but foreman-maintain version installed does not support it')
  end
end

# unlock packages if locked
if system('foreman-maintain packages is-locked --assumeyes > /dev/null 2>&1')
  log_and_say :info, "Package versions are locked. Continuing with unlock."
  execute('foreman-maintain packages unlock --assumeyes', false)
end
nil
