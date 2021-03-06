#!/bin/bash -ex

DOMAIN=mydomain.com
HOSTNAME=myhost01
FQDN=$HOSTNAME.$DOMAIN
hostname $FQDN
echo $FQDN > /etc/hostname

cat<<EOF > /etc/hosts
127.0.0.1 localhost
$LOCIP $HOSTNAME.$DOMAIN $HOSTNAME

::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

export DEBIAN_FRONTEND='noninteractive'
apt-get update
apt-get -y install htop lsof iftop tcpdump exim4
apt-get -y purge apparmor*
umount /mnt
apt-get -y install lvm2
pvcreate  /dev/xvdb /dev/xvdc
vgcreate vg  /dev/xvdb /dev/xvdc
lvcreate -i2 -L200G -n mysqldata vg
lvcreate -i2 -L10G -n mysqllogs vg
lvcreate -i2 -L50G -n mysqlbinlogs vg
lvcreate -i2 -L50G -n mysqlrelaylogs vg
lvcreate -i2 -L0.5T -n data vg
mkfs -t ext4 /dev/vg/mysqldata
mkfs -t ext4 /dev/vg/mysqllogs
mkfs -t ext4 /dev/vg/mysqlbinlogs
mkfs -t ext4 /dev/vg/mysqlrelaylogs
mkfs -t ext4 /dev/vg/data
mkdir -pv /mnt/mysql/relaylogs /mnt/mysql/binlogs /data /var/lib/mysql /var/log/mysql

cat<<EOF > /etc/fstab
LABEL=cloudimg-rootfs	/	 ext4	defaults	0 0
/dev/vg/mysqldata       /var/lib/mysql        ext4 defaults,nobootwait,comment=cloudconfig 0 2
/dev/vg/mysqllogs       /var/log/mysql        ext4 defaults,nobootwait,comment=cloudconfig 0 2
/dev/vg/data            /data                 ext4 defaults,nobootwait,comment=cloudconfig 0 2
/dev/vg/mysqlrelaylogs  /mnt/mysql/relaylogs  ext4 defaults,nobootwait,comment=cloudconfig 0 2
/dev/vg/mysqlbinlogs    /mnt/mysql/binlogs    ext4 defaults,nobootwait,comment=cloudconfig 0 2
EOF

mount -av

cat<<EOF > /etc/apt/sources.list.d/percona.list
deb http://repo.percona.com/apt oneiric main
deb-src http://repo.percona.com/apt oneiric main
EOF

gpg --keyserver  hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
gpg -a --export CD2EFD2A | apt-key add -
apt-get update
apt-get -y upgrade
apt-get -yq install percona-server-server-5.5 percona-server-client-5.5 xtrabackup
chown -Rv mysql.mysql /mnt/mysql

reboot
