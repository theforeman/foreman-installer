lock_packages = get_custom_config(:lock_package_versions)
Kafo::Helpers.execute('foreman-maintain packages lock --assumeyes') if lock_packages
