#!/usr/bin/ruby

slaveStatus = %x[HOME=/root mysql -e 'show slave status\\G']
File.open('/var/tmp/a', 'w') {|f| f.write(slaveStatus) }
if 
  slaveStatus.match('Slave_IO_Running: Yes') and 
  #slaveStatus.match('Slave_IO_Running: No') and 
  slaveStatus.match('Slave_SQL_Running: Yes') and
  slaveStatus.match('Seconds_Behind_Master: 0') do 
  $stderr.puts("RUNNING")
  exit(0)
end
else 
  $stderr.puts("STOPPED")
  exit(1)
end

