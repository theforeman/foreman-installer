#!/usr/bin/env ruby
# Check to verify forward / reverse dns matches hostname
require 'ipaddr'
require 'resolv'
require 'socket'

def error_exit(message, code=2)
  $stderr.puts message
  exit code
end

hostname = `hostname -f`.chomp
forwards = Resolv.getaddresses(hostname)

if forwards.empty?
  error_exit("Unable to resolve forward DNS for #{hostname}")
end

ips = Socket.ip_address_list.reject(&:ipv6_linklocal?).map { |addr| IPAddr.new(addr.ip_address) }

forwards.each do |ip|
  ip = IPAddr.new(ip)
  unless ips.include?(ip)
    error_exit("Forward DNS points to #{ip} which is not configured on this server")
  end

  reverse = Resolv.getname(ip.to_s)
  unless hostname == reverse
    error_exit("Reverse DNS #{reverse} does not match hostname #{hostname}")
  end
end
