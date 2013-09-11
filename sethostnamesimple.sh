#!/bin/bash

DOMAIN=pctal.net

LOCIP=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-ipv4`

HOSTNAME=puppetmaster001
FQDN=$HOSTNAME.$DOMAIN
echo $HOSTNAME

hostname $FQDN
echo $FQDN > /etc/hostname

cat<<EOF > /etc/hosts
# This file is automatically genreated by ec2-hostname script
127.0.0.1 localhost
$LOCIP $HOSTNAME.$DOMAIN $HOSTNAME

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

# below for Redhat-types, remove either before this line or after

#!/bin/bash

DOMAIN=c3-prod.internal

LOCIP=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-ipv4`

HOSTNAME=prod-c3-haproxy-03
FQDN=$HOSTNAME.$DOMAIN

hostname $FQDN

sed -i '/'$LOCIP'/d' /etc/hosts
echo $LOCIP  $FQDN $HOSTNAME >> /etc/hosts

sed -i "s/HOSTNAME=.*/HOSTNAME=${FQDN}/" /etc/sysconfig/network

service network restart
