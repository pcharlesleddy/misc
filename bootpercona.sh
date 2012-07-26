#!/bin/bash -ex

export DEBIAN_FRONTEND='noninteractive'

apt-get -y install htop lsof iftop tcpdump exim4
apt-get -y install mdadm
apt-get -y purge apparmor*



umount /mnt
yes | mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/xvdb /dev/xvdc
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
mdadm --detail /dev/md0


apt-get -y install lvm2
pvcreate /dev/md0
vgcreate vg /dev/md0
lvcreate -L200G -n mysqldata vg
lvcreate -L10G -n mysqllogs vg
lvcreate -L50G -n mysqlbinlogs vg
lvcreate -L50G -n mysqlrelaylogs vg
lvcreate -L0.5T -n data vg


mkfs -t ext4 /dev/vg/mysqldata
mkfs -t ext4 /dev/vg/mysqllogs
mkfs -t ext4 /dev/vg/mysqlbinlogs
mkfs -t ext4 /dev/vg/mysqlrelaylogs
mkfs -t ext4 /dev/vg/data


mkdir -pv /mnt/mysql/relaylogs /mnt/mysql/binlogs /data /var/lib/mysql /var/log/mysql

cat<<EOF > /etc/fstab
LABEL=cloudimg-rootfs	/	 ext4	defaults	0 0
#/dev/xvdb	/mnt	auto	defaults,nobootwait,comment=cloudconfig	0	2
/dev/vg/mysqldata       /var/lib/mysql        ext4 defaults,nobootwait,comment=cloudconfig 0 2
/dev/vg/mysqllogs       /var/log/mysql        ext4 defaults,nobootwait,comment=cloudconfig 0 2
/dev/vg/data            /data                 ext4 defaults,nobootwait,comment=cloudconfig 0 2
/dev/vg/mysqlrelaylogs  /mnt/mysql/relaylogs  ext4 defaults,nobootwait,comment=cloudconfig 0 2
/dev/vg/mysqlbinlogs    /mnt/mysql/binlogs    ext4 defaults,nobootwait,comment=cloudconfig 0 2
EOF

mount -av

cat<<EOF > /etc/apt/sources.list.d/percona.list
# Percona
deb http://repo.percona.com/apt oneiric main
deb-src http://repo.percona.com/apt oneiric main
EOF

gpg --keyserver  hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
gpg -a --export CD2EFD2A | apt-key add -
apt-get update
apt-get -y upgrade
apt-get -yq install percona-server-server-5.5 percona-server-client-5.5 xtrabackup


chown -Rv mysql.mysql /mnt/mysql

DOMAIN=blarg.com

LOCIP=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-ipv4`
echo $LOCIP
IPV4=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/public-ipv4`
echo $IPV4
INSTANCE_ID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id | cut -d- -f2`
echo $INSTANCE_ID
REGION=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | cut -d- -f1-2`
echo $REGION
HOSTNAME=pDb-$REGION-$INSTANCE_ID
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
