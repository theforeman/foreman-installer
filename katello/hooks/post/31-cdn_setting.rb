if !app_value(:noop) && katello_enabled?
  param = get_custom_config('cdn_ssl_version')
  if param
    logger.info 'cdn_ssl_version param found, migrating to a Katello setting'
    execute("foreman-rake -- config -k cdn_ssl_version -v '#{param}'")
    store_custom_config('cdn_ssl_version', nil)
  else
    logger.debug 'cdn_ssl_version already migrated, skipping'
  end
end
