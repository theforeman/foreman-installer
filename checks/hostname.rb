#!/usr/bin/env ruby

require 'English'

def error_exit(message, code)
  $stderr.puts message
  exit code
end

MISSING = "Command 'facter' does not exist in system executable path

Make sure the above command is installed and executable in your system. ".freeze

ENV['PATH'] = ENV['PATH'].split(File::PATH_SEPARATOR).push('/opt/puppetlabs/bin').join(File::PATH_SEPARATOR)

system("which facter > /dev/null 2>&1")
error_exit(MISSING, 3) if $CHILD_STATUS.exitstatus == 1

facter_fqdn = `facter fqdn`.chomp
hostname_f = `hostname -f`.chomp

BASE = "If needed, change the hostname permanently via the
'hostname' or 'hostnamectl set-hostname' command
and editing the appropriate configuration file.
(e.g. on Red Hat systems /etc/sysconfig/network,
on Debian based systems /etc/hostname).

If 'hostname -f' still returns an unexpected result, check /etc/hosts and put
the hostname entry in the correct order, for example:

  1.2.3.4 hostname.example.com hostname

The fully qualified hostname must be the first entry on the line".freeze

DIFFERENT = "Output of 'facter fqdn' (#{facter_fqdn}) is different from 'hostname -f' (#{hostname_f})

Make sure above command gives the same output. ".freeze

INVALID = "Output of 'hostname -f' (#{hostname_f}) does not seems to be valid FQDN

Make sure above command gives fully qualified domain name. At least one
dot must be present and underscores are not allowed. ".freeze

UPCASE = "The hostname (#{facter_fqdn}) contains a capital letter.

This is not supported. Please modify the hostname to be all lowercase. ".freeze

# Check that facter actually has a value that matches the hostname.
# This should always be true for facter >= 1.7
error_exit(DIFFERENT + BASE, 1) if facter_fqdn != hostname_f
# Every FQDN should have at least one dot
error_exit(INVALID + BASE, 2) unless facter_fqdn.include?('.')
# Per https://bugzilla.redhat.com/show_bug.cgi?id=1205960 check for underscores
error_exit(INVALID + BASE, 2) if facter_fqdn.include?('_')
# Capital Letters are not suported.
error_exit(UPCASE + BASE, 3) if facter_fqdn.downcase != facter_fqdn
