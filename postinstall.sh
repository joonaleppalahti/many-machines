sudo tftp 172.28.172.136 -c get firstboot
sudo mv firstboot /etc/init.d/
sudo chmod +x /etc/init.d/firstboot
update-rc.d firstboot defaults
