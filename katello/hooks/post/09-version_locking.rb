lock_packages = get_custom_config(:lock_package_versions)
Kafo::Helpers.execute('foreman-maintain installation lock --assumeyes') if lock_packages
