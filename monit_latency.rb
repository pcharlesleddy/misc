#!/usr/bin/ruby

latency = %x[ping -q -c 3 vpn.corp.glossybox.net | grep 'rtt' | awk -F= '{print $2}' | awk -F/ '{print $2}' | tr -d ' ']

if latency.to_i > 15 
  $stderr.puts('Packet loss high: ' + latency)
  exit(1)
else
  $stderr.puts('Packet loss OK: ' + latency)
  exit(0)
end
