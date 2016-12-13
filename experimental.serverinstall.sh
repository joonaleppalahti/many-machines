#!/bin/bash

# Replace with your default gateway
serverdefgateway=192.168.1.1

# Replace "enp0s3" with your network card ID
serversubnet=$(facter | grep "network_enp0s3" | sed 's/^network_enp0s3 => //')

filepath=/home/joona/many-machines
serverip=$(facter | grep "ipaddress =>" | sed 's/^ipaddress => //')
serverinterface=$(facter | grep interfaces | sed 's/^interfaces => //' | sed 's/\,.*//')
servernetmask=$(facter | grep "netmask =>" | sed 's/^netmask => //')

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

sudo cp -rv $filepath/puppet /etc/


sudo cat <<EOF > /etc/puppet/puppet.conf

[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/run/puppet
factpath=$vardir/lib/facter
prerun_command=/etc/puppet/etckeeper-commit-pre
postrun_command=/etc/puppet/etckeeper-commit-post

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN 
ssl_client_verify_header = SSL_CLIENT_VERIFY
dns_alt_names = PXEMaster.local, $serverip
autosign = true

EOF

sudo apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install -y puppetmaster wakeonlan isc-dhcp-server tftpd-hpa squid-deb-proxy

sudo wget https://atlas.hashicorp.com/hashicorp/boxes/precise64/versions/1.1.0/providers/virtualbox.box -O /etc/puppet/modules/physical/files/precise64.box
sudo wget http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/netboot/netboot.tar.gz -O /var/lib/tftpboot/netboot.tar.gz
sudo tar -xvf /var/lib/tftpboot/netboot.tar.gz -C /var/lib/tftpboot/


sudo cat <<EOF > /var/lib/tftpboot/ubuntu-installer/amd64/preseed.cfg

d-i mirror/http/proxy string http://$serverip:8000/

d-i passwd/user-fullname string Joona Leppälahti
d-i passwd/username string joona
d-i passwd/user-password password SalaKaval4
d-i passwd/user-password-again password SalaKaval4

d-i partman-auto/method string regular

d-i partman-lvm/device_remove_lvm boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true

d-i partman-auto/choose_recipe select atomic

d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

d-i pkgsel/include string puppet ssh tftp-hpa avahi-daemon

d-i pkgsel/update-policy select none

d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true

d-i finish-install/reboot_in_progress note

d-i preseed/late_command string \
in-target tftp $serverip -c get postinstall.sh ; \
in-target sudo /bin/bash postinstall.sh

EOF


sudo cat <<EOF > /etc/default/isc-dhcp-server

INTERFACES="$serverinterface"

EOF


sudo cat <<EOF > /var/lib/tftpboot/postinstall.sh

sudo tftp $serverip -c get firstboot
sudo mv firstboot /etc/init.d/
sudo chmod +x /etc/init.d/firstboot
update-rc.d firstboot defaults

EOF


sudo cat <<EOF > /var/lib/tftpboot/ubuntu-installer/amd64/boot-screens/syslinux.cfg

# D-I config version 2.0
# search path for the c32 support libraries (libcom32, libutil etc.)
path ubuntu-installer/amd64/boot-screens/
include ubuntu-installer/amd64/boot-screens/menu.cfg
default ubuntu-installer/amd64/boot-screens/vesamenu.c32

label joonapxe
        kernel ubuntu-installer/amd64/linux
        append initrd=ubuntu-installer/amd64/initrd.gz auto=true auto url=tftp://$serverip/ubuntu-installer/amd64/preseed.cfg locale=en_US.UTF-8 classes=minion DEBCONF_DEBUG=5 priority=critical preseed/url/=ubuntu-installer/amd64/preseed.cfg netcfg/choose_interface=auto

prompt 1
timeout 5
default joonapxe

EOF


sudo cat <<EOF > /etc/dhcp/dhcpd.conf

ddns-update-style none;

default-lease-time 600;
max-lease-time 7200;

authoritative;

log-facility local7;

next-server $serverip;
filename "pxelinux.0";

subnet $serversubnet netmask $servernetmask {

	option subnet-mask $servernetmask;
	option routers $serverdefgateway;
	option domain-name-servers 8.8.8.8, 8.8.4.4;

	host testclient {
		hardware ethernet 00:21:85:01:6e:2e;
		fixed-address 192.168.1.8;
	}

	host client1 {
		hardware ethernet 78:ac:c0:c0:8e:27;
		fixed-address 172.28.63.100;
	}

	host client2 {
		hardware ethernet 78:ac:c0:ba:7b:63;
		fixed-address 172.28.63.101;
	}

	host client3 {
		hardware ethernet 78:ac:c0:c1:1b:61;
		fixed-address 172.28.63.102;
	}

	host client4 {
		hardware ethernet e8:39:35:3f:50:91;
		fixed-address 172.28.63.25;
	}

        host client5 {
                hardware ethernet e8:39:35:3f:4f:1a;
                fixed-address 172.28.63.104;
        }

        host client6 {
                hardware ethernet 2c:27:d7:19:01:43;
                fixed-address 172.28.63.21;
        }

        host client7 {
                hardware ethernet 78:ac:c0:c4:08:dc;
                fixed-address 172.28.63.105;
        }

        host client8 {
                hardware ethernet 78:ac:c0:ba:74:e6;
                fixed-address 172.28.63.16;
        }

        host client9 {
                hardware ethernet 78:ac:c0:c1:04:a5;
                fixed-address 172.28.63.106;
        }

        host client10 {
                hardware ethernet 78:ac:c0:c1:0a:96;
                fixed-address 172.28.63.107;
        }

        host client11 {
                hardware ethernet 78:ac:c0:c0:8f:a1;
                fixed-address 172.28.63.108;
        }

        host client12 {
                hardware ethernet 78:ac:c0:c1:05:cd;
                fixed-address 172.28.63.109;
        }

        host client13 {
                hardware ethernet 78:ac:c0:ba:7d:2f;
                fixed-address 172.28.63.110;
        }

        host client14 {
                hardware ethernet 78:ac:c0:ba:7c:f7;
                fixed-address 172.28.63.111;
        }

        host client15 {
                hardware ethernet 78:ac:c0:ba:7b:65;
                fixed-address 172.28.63.112;
        }

        host client16 {
                hardware ethernet 78:ac:c0:ba:76:26;
                fixed-address 172.28.63.113;
        }

        host client17 {
                hardware ethernet 78:ac:c0:c0:8b:2a;
                fixed-address 172.28.63.114;
        }

        host client18 {
                hardware ethernet 78:ac:c0:c0:8a:91;
                fixed-address 172.28.63.115;
        }

        host client19 {
                hardware ethernet 2c:27:d7:19:01:83;
                fixed-address 172.28.63.116;
        }

        host client20 {
                hardware ethernet 78:ac:c0:ba:7c:ec;
                fixed-address 172.28.63.117;
        }

        host client21 {
                hardware ethernet 78:ac:c0:ba:77:ac;
                fixed-address 172.28.63.118;
        }

        host client22 {
                hardware ethernet 78:ac:c0:ba:75:e4;
                fixed-address 172.28.63.119;
        }

        host client23 {
                hardware ethernet 78:ac:c0:c0:8a:de;
                fixed-address 172.28.63.120;
        }

        host client24 {
                hardware ethernet 78:ac:c0:c1:09:b6;
                fixed-address 172.28.63.121;
        }

        host client25 {
                hardware ethernet 78:ac:c0:c0:88:49;
                fixed-address 172.28.63.123;
        }

        host client26 {
                hardware ethernet 78:ac:c0:c1:11:03;
                fixed-address 172.28.63.124;
        }
}

EOF

sudo service isc-dhcp-server restart

sudo cp -v $filepath/firstboot /var/lib/tftpboot/
sudo cp -v $filepath/provision.sh /etc/puppet/modules/physical/templates

echo "done"
