#!/usr/bin/ruby

host = ARGV[0]

packet_loss = %x[ping -q -c 10 #{host} | grep 'packet loss' | awk -F, '{print $3}' | awk -F% '{print $1}' | tr -d ' ']

if packet_loss.to_i > 0
  $stderr.puts('Packet loss high: ' + packet_loss.chomp + '%' + " (#{host})")
  exit(1)
else
  $stderr.puts('Packet loss OK: ' + packet_loss.chomp + '%' + " (#{host})")
  exit(0)
end
