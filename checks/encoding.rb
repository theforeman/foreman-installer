#!/usr/bin/env ruby

INVALID_ENCODING = 'The system encoding is not set to UTF-8.'.freeze

def error_exit(message, code)
  $stderr.puts message
  exit code
end

error_exit(INVALID_ENCODING, 1) if Encoding.locale_charmap != 'UTF-8'
