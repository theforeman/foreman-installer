if app_value(:lock_package_versions)
  log_and_say :info, "Package versions are being locked."
  lock_packages
end
