packet_loss = %x[ping -q -c 10 vpn.corp.glossybox.net | grep 'packet loss' | awk -F, '{print $3}' | awk -F% '{print $1}' | tr -d ' ']

if packet_loss.to_i > 2 
  $stderr.puts('Packet loss high: ' + packet_loss.chomp + '%')
  exit(1)
else
  $stderr.puts('Packet loss OK: ' + packet_loss.chomp + '%')
  exit(0)
end
