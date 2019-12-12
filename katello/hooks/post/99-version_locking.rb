if get_custom_config(:lock_package_versions)
  log_and_say :info, "Package versions are being locked."
  execute('foreman-maintain packages lock --assumeyes', false)
end
