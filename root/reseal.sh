#!/bin/sh

[ -z "$1" ] && { echo "Usage: $0 reseal"; exit; }
. /etc/profile.d/z-local.sh

cd
date +"%Y-%m-%d" > /etc/ubuntu-sealed
perl -pi -e '$_="" if /KERNEL.*?eth/' /etc/udev/rules.d/70-persistent-net.rules 
rm -f /etc/ubuntu-firstrun
rm -f /home/local/.bash_history /home/local/.ssh/*
rm -f /root/{.bash_history,.joe_state,.pwd,.lesshst,.viminfo,ubuntu_environment_*.tar.gz} /root/.ssh/{authorized_keys,id_rsa,id_rsa.pub,config}
rm -f /tmp/dhclient.env /var/lib/dhcp3/dhclient.*
/usr/local/lib/cemosshe/cemosshe.uninstall ; rm -rf /usr/local/lib/cemosshe/uninstall
/usr/local/lib/snarsshe/snarsshe.uninstall
echo -n > /root/.ssh/known_hosts
/root/backup_ubuntu_environment.sh
/sbin/shutdown -h now
