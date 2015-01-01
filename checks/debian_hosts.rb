#!/usr/bin/env ruby

MESSAGE = %q(Ensure that
ping $(hostname -f)
shows the real IP address, not 127.0.1.1.

Change or remove this entry from /etc/hosts
)

def match_hosts_entry
  File.open('/etc/hosts').grep(/^127\.0\.1\.1/).count
end

def error_exit(message, code)
  $stderr.puts message
  exit code
end

error_exit(MESSAGE, 1) if (match_hosts_entry > 0)
