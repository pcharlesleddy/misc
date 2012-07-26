#!/bin/bash

DOMAIN=aupeo.com

LOCIP=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
echo $LOCIP
IPV4=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
echo $IPV4
INSTANCE_ID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id | cut -d- -f2`
echo $INSTANCE_ID
REGION=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | cut -d- -f1-2`
echo $REGION
HOSTNAME=webapp-$REGION-$INSTANCE_ID
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
