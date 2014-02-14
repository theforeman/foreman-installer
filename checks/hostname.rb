#!/usr/bin/env ruby

begin
  require 'rubygems'
rescue LoadError
end
require 'facter'

BASE = %q(If needed, change the hostname permanently via 'hostname' command and editing 
appropriate configuration file.
(e.g. on Red Hat systems /etc/sysconfig/network).

If 'hostname -f' still returns unexpected result, check /etc/hosts and put
hostname entry in the correct order, for example:
 
  1.2.3.4 full.hostname.com full
 
Fully qualified hostname must be the first entry on the line)

DIFFERENT = %q(Output of 'facter fqdn' is different from 'hostname -f'
 
Make sure above command gives the same output. )

INVALID = %q(Output of 'hostname -f' does not seems to be valid FQDN

Make sure above command gives fully qualified domain name. At least one
dot must be present. )
 

def error_exit(message, code)
  $stderr.puts message
  exit code
end

# Check that facter actually has a value that matches the hostname.
# This should always be true for facter >= 1.7
error_exit(DIFFERENT + BASE, 1) if Facter.value(:fqdn) != `hostname -f`.chomp
# Every FQDN should have at least one dot
error_exit(INVALID + BASE, 2) unless Facter.value(:fqdn).include?('.')
