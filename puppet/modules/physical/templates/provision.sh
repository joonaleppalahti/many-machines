#!/bin/bash

apt-get update
apt-get -y install avahi-daemon
apt-get -y install puppet

service puppet stop

sethost=t$RANDOM$RANDOM$RANDOM
hostname $sethost

cat <<EOF > /etc/hosts

127.0.0.1       localhost
127.0.1.1       ubuntu $sethost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

EOF

service avahi-daemon restart

cat <<EOF > /etc/puppet/puppet.conf

[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/run/puppet
factpath=$vardir/lib/facter
prerun_command=/etc/puppet/etckeeper-commit-pre
postrun_command=/etc/puppet/etckeeper-commit-post

[master]
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY

[agent]
server = 192.168.1.129

EOF

cat <<EOF > /etc/default/puppet

START=yes

DAEMON_OPTS=""

EOF

# Doesn't require deletion of certs
# Left this here just in case
# rm -r /var/lib/puppet/ssl

puppet agent --enable
service puppet restart
