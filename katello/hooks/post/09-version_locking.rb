if get_custom_config(:lock_package_versions)
  Kafo::Helpers.log_and_say :info, "Package versions are being locked."
  Kafo::Helpers.execute('foreman-maintain packages lock --assumeyes', false)
end
