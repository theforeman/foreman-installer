#!/usr/bin/env ruby

INVALID_LANG = %q(The LANG environment variable should not be set to C)
INVALID_LC_ALL = %q(The LC_ALL environment variable should not be set to C)

def error_exit(message, code)
  $stderr.puts message
  exit code
end

error_exit(INVALID_LANG, 1) if ENV["LANG"] == "C"
error_exit(INVALID_LC_ALL, 1) if ENV["LC_ALL"] == "C"
