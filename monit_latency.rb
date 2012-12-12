#!/usr/bin/ruby

host = ARGV[0]

latency = %x[ping -q -c 3 #{host} | grep 'rtt' | awk -F= '{print $2}' | awk -F/ '{print $2}' | tr -d ' ']

if latency.to_i > 30 
  $stderr.puts('Latency high: ' + latency.chomp + ' ms' + " (#{host})" )
  exit(1)
else
  $stderr.puts('Latency OK: ' + latency.chomp + ' ms' + " (#{host})")
  exit(0)
end
