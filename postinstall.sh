sudo tftp 172.28.171.121 -c get firstboot
sudo mv firstboot /etc/init.d/
sudo chmod +x /etc/init.d/firstboot
update-rc.d firstboot defaults
