#!/usr/bin/env ruby

BASE = %q(If needed, change the hostname permanently via the
'hostname' or 'hostnamectl set-hostname' command 
and editing the appropriate configuration file.
(e.g. on Red Hat systems /etc/sysconfig/network, 
on Debian based systems /etc/hostname).

If 'hostname -f' still returns an unexpected result, check /etc/hosts and put
the hostname entry in the correct order, for example:
 
  1.2.3.4 full.hostname.com full
 
The fully qualified hostname must be the first entry on the line)

DIFFERENT = %q(Output of 'facter fqdn' is different from 'hostname -f'
 
Make sure above command gives the same output. )

INVALID = %q(Output of 'hostname -f' does not seems to be valid FQDN

Make sure above command gives fully qualified domain name. At least one
dot must be present. )
 

def error_exit(message, code)
  $stderr.puts message
  exit code
end

ENV['PATH'] = ENV['PATH'].split(File::PATH_SEPARATOR).concat(['/opt/puppetlabs/bin']).join(File::PATH_SEPARATOR)
facter_fqdn = `facter fqdn`.chomp

# Check that facter actually has a value that matches the hostname.
# This should always be true for facter >= 1.7
error_exit(DIFFERENT + BASE, 1) if facter_fqdn != `hostname -f`.chomp
# Every FQDN should have at least one dot
error_exit(INVALID + BASE, 2) unless facter_fqdn.include?('.')
