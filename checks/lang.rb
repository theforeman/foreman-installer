#!/usr/bin/env ruby

INVALID_LANG = 'The LANG environment variable should not be set to C'.freeze
INVALID_LC_ALL = 'The LC_ALL environment variable should not be set to C'.freeze

def error_exit(message, code)
  $stderr.puts message
  exit code
end

error_exit(INVALID_LANG, 1) if ENV["LANG"] == "C"
error_exit(INVALID_LC_ALL, 1) if ENV["LC_ALL"] == "C"
