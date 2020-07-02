def package_lock_feature?
  foreman_maintain('packages -h')
end

if package_lock_feature?
  app_option(
    '--[no-]lock-package-versions',
    :flag,
    "Let installer lock versions of the installed packages to prevent\n" \
      "unexpected breakages during system updates. The choice is remembered\n" \
      "and used in next installer runs.",
    :default => nil
  )
end
