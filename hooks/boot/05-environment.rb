%w[http_proxy https_proxy ssl_cert_file HTTP_PROXY HTTPS_PROXY SSL_CERT_FILE].each do |variable|
  if ::ENV.delete(variable) # rubocop:disable Style/RedundantConstantBase
    logger.warn "Unsetting environment variable '#{variable}' for the duration of the install."
  end
end
