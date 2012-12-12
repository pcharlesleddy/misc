active_calls = %x[/usr/sbin/asterisk -rx 'core show calls' | grep active | awk '{print $1}']

if active_calls.to_i > 2 
  $stderr.puts('Active calls high: ' + active_calls)
  exit(1)
else
  $stderr.puts('Active calls OK: ' + active_calls)
  exit(0)
end
