#!/bin/sh

[ -z "$1" ] && { echo "Usage: $0 reseal"; exit; }
. /etc/profile.d/z-local.sh

cd
date +"%Y-%m-%d" > /etc/ubuntu-sealed
perl -pi -e '$_="" if /KERNEL.*?eth/' /etc/udev/rules.d/70-persistent-net.rules 
rm -f /etc/ubuntu-firstrun
rm -f /home/local/{.bash_history,.pwd,.sudo_as_admin_successful} /home/local/.ssh/*
rm -rf /home/local/.cache
rm -f /root/{.bash_history,.joe_state,.pwd,.lesshst,.viminfo,.gitconfig} /root/.ssh/{authorized_keys,id_rsa,id_rsa.pub,config} /.git
rm -rf /root/{.aptitude,.debtags}
rm -f /tmp/dhclient.env /var/lib/dhcp3/dhclient.* /tmp/checkip
/usr/local/lib/cemosshe/cemosshe.uninstall ; rm -rf /usr/local/lib/cemosshe/uninstall
/usr/local/lib/snarsshe/snarsshe.uninstall
echo -n > /root/.ssh/known_hosts
/sbin/shutdown -h now
