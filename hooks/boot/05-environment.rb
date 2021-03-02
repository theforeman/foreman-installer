%w[http_proxy https_proxy ssl_cert_file HTTP_PROXY HTTPS_PROXY SSL_CERT_FILE].each do |variable|
  if ENV.delete(variable)
    $stderr.puts "Unsetting environment variable #{variable}"
  end
end
