#!/usr/bin/env ruby

variables = %w[http_proxy https_proxy ssl_cert_file
               HTTP_PROXY HTTPS_PROXY SSL_CERT_FILE]

if variables.map { |variable| ENV[variable] }.compact.any?
  $stderr.puts "Please unset the following environment variables before running the installer: #{variables.join(', ')}"
  exit 1
end
