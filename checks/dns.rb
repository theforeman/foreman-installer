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

  begin
    reverse = Resolv.getname(ip.to_s)
    unless hostname == reverse
      error_exit("Reverse DNS failed. Looking up #{ip} gave #{reverse}, expected to match #{hostname}")
    end
  rescue Resolv::ResolvError
    # Because of https://bugs.ruby-lang.org/issues/12112:
    if ip.ipv6?
      reverse = Resolv::DNS.open do |dns|
        dns.getresources ip.ip6_arpa, Resolv::DNS::Resource::IN::PTR
      end.first
      next if reverse && hostname == reverse.name.to_s
    end

    error_exit("Forward DNS #{ip} did not reverse resolve to any hostname.")
  end
end
