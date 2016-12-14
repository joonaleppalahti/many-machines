# Automatically configure virtual machines in physical machines using PXE, Puppet and Vagrant 

## Some assembly required! Edit config files and run `sudo serverinstall.sh` to set up server

### Edit these files in many-machines directory, before running serverinstall.sh.
Below are their paths if you need to edit them later.

* /var/lib/tftpboot/ubuntu-installer/amd64/preseed.cfg
* /var/lib/tftpboot/ubuntu-installer/amd64/boot-screens/syslinux.cfg
* /etc/default/isc-dhcp-server
* /etc/dhcp/dhcpd.conf
* /var/lib/tftpboot/postinstall.sh
* /etc/puppet/puppet.conf
* /etc/puppet/modules/physical/templates/provision.sh

`Wakeonlan 12:34:56:78:90:ab` to wake up target machine. Installations might take a while,
but at the end the target machine should be running Ubuntu 16.04 64-bit. Inside the target machine
should be Ubuntu 12.04 64-bit virtual machines running with VirtualBox and Vagrant. Username used for configurations
is "joona", you need to edit multiple files to change it.

## experimental.serverinstall.sh

I made a new installation script that handles almost everything. You only need to change server IP-address on line 44 in provision.sh in many-machines directory, default gateway on line 4 in experimental.serverinstall.sh and both instances of "enp0s3" on line 7 to match your network adapter. After making the changes, run ´sudo ./experimental.serverinstall.sh´ and the server should be configured in a minute.

### Sources used

* http://terokarvinen.com/2016/aikataulu-palvelinten-hallinta-ict4tn022-1-5-op-uusi-ops-loppusyksy-2016
* https://help.ubuntu.com/lts/installation-guide/armhf/apbs02.html
* https://askubuntu.com/questions/617558/preseed-doesnt-automatically-select-network-interface-on-ubuntu-14-04-automate
* https://help.ubuntu.com/lts/installation-guide/example-preseed.txt
* https://ubuntuforums.org/showthread.php?t=1977570
* http://www.50ply.com/blog/2012/07/16/automating-debian-installs-with-preseed-and-puppet/
* https://stackoverflow.com/questions/2500436/how-does-cat-eof-work-in-bash
* https://askubuntu.com/questions/104899/make-apt-get-or-aptitude-run-with-y-but-not-prompt-for-replacement-of-configu
* https://stackoverflow.com/questions/17310333/require-puppet-to-place-a-file-before-starting-service/17316902#17316902
* https://serverfault.com/questions/586472/puppet-create-service-before-file-but-notify-service-if-file-changes/587199#587199
* https://eureka.ykyuen.info/2014/09/23/puppet-run-exec-as-a-specific-user/
* https://stackoverflow.com/questions/30194647/puppet-set-global-timeout-for-exec
* http://grokbase.com/t/gg/puppet-users/1276gp4kxy/how-do-i-cd-change-directory-with-puppets-exec
* https://docs.puppet.com/puppet/3.8/lang_node_definitions.html#regular-expression-names
* https://manski.net/2016/09/vagrant-multi-machine-tutorial/
* https://www.vagrantup.com/docs/vagrantfile/machine_settings.html
* https://askubuntu.com/questions/520080/remove-the-first-part-of-a-string-using-sed
* https://stackoverflow.com/questions/18602234/sed-to-remove-everything-after-in-file-using-command
