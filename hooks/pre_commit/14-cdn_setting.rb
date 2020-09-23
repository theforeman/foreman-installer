if katello_enabled? &&
   @kafo.config.answers['katello'].is_a?(Hash) &&
   @kafo.config.answers['katello'].key?('cdn_ssl_version')
  # Using @kafo.config.answers because param() goes through PuppetModule. At
  # this point the parameter doesn't exist in the module on disk so param()
  # returns nil.
  value = @kafo.config.answers['katello']['cdn_ssl_version']
  if value
    logger.info 'cdn_ssl_version parameter found, storing for post hook'
    store_custom_config('cdn_ssl_version', value)
  end
end
