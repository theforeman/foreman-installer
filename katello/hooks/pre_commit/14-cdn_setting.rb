if module_enabled?('katello')
  # Using @kafo.config.answers because param() goes through PuppetModule. At
  # this point the parameter doesn't exist in the module on disk so param()
  # returns nil.
  value = @kafo.config.answers['katello']['cdn_ssl_version']
  if value
    logger.info 'cdn_ssl_version parameter found, storing for post hook'
    store_custom_config('cdn_ssl_version', value)
  else
    logger.debug 'cdn_ssl_version already migrated, skipping'
  end
end
