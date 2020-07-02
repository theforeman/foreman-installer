def lock_packages
  foreman_maintain!('packages lock --assumeyes')
end

if get_custom_config(:lock_package_versions)
  log_and_say :info, "Package versions are being locked."
  lock_packages
end
