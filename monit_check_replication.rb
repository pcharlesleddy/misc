#!/usr/bin/ruby

slaveStatus = %x[HOME=/root mysql -e 'show slave status\\G']
File.open('/var/tmp/a', 'w') {|f| f.write(slaveStatus) }
if slaveStatus.match('Slave_IO_Running: Yes') and slaveStatus.match('Slave_SQL_Running: Yes') and ( slaveStatus.match(/Seconds_Behind_Master: (\d+)/)[1].to_i < 100 ) 
  $stderr.puts("RUNNING:" + slaveStatus.match(/Seconds_Behind_Master: (\d+)/)[1])
  exit(0)
else 
  $stderr.puts("STOPPED: " + slaveStatus.match(/Seconds_Behind_Master: (\d+)/)[1])
  exit(1)
end
