#!/usr/bin/ruby

require 'logger'

log = Logger.new('/var/log/cassandra/repair.log', 'daily')
log.level = Logger::INFO
log.datetime_format = "%Y-%m-%d %H:%M:%S"

keyspaces = {}

result = %x[nodetool cfstats | egrep 'Keyspace:|Column Family:']
result = result.gsub(/\s/, '')
#log.debug(result.inspect)

result.split("Keyspace:").each do | keyspace |
  #log.debug(keyspace.inspect)
  keyname = keyspace.split("ColumnFamily:")[0]
  next if (keyname == nil)
  next if (keyname == 'OpsCenter' or keyname == 'system')
  #log.debug(keyname.inspect)
  cfs = keyspace.split("ColumnFamily:").drop(1)
  keyspaces[keyname] = cfs
end
#log.debug(keyspaces.inspect)

keyspaces.keys.each {|x|
  keyspaces[x].each do |y|
    log.info("Repair start: #{x} #{y}")
#    result = %x[nodetool getcompactionthreshold #{x} #{y}]
#    log.info(result)
    log.info("Repair end: #{x} #{y}")
  end
}
