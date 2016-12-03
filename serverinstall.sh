#!/bin/bash
# Tested on live Xubuntu 16.04.1 64-bit

sudo cat <<EOF > /etc/hosts

127.0.0.1 localhost
127.0.1.1 xubuntu PXEMaster

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts

EOF

sudo hostnamectl set-hostname PXEMaster
sudo service avahi-daemon restart

filepath=/home/xubuntu/many-machines

sudo cp -r $filepath/puppet /etc/

sudo apt-get -y install puppetmaster wakeonlan isc-dhcp-server tftpd-hpa

sudo cp $filepath/manyisc-dhcp-server /etc/default/
sudo cp $filepath/dhcpd.conf /etc/dhcp/

sudo service isc-dhcp-server restart

sudo wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/netboot.tar.gz -O /var/lib/tftpboot/netboot.tar.gz
sudo tar -xvf /var/lib/tftpboot/netboot.tar.gz -C /var/lib/tftpboot/

sudo cp $filepath/syslinux.cfg /var/lib/tftpboot/ubuntu-installer/amd64/boot-screens/
sudo cp $filepath/preseed.cfg /var/lib/tftpboot/ubuntu-installer/amd64/
sudo cp $filepath/postinstall.sh /var/lib/tftpboot/
sudo cp $filepath/firstboot /var/lib/tftpboot/
