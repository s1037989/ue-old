#!/bin/bash

# This should be make into a package to avoid overwriting post-run changes

[ -z "$1" ] && { echo "Usage: $0 code fqdn [force]"; exit; }
[ -z "$2" ] && { echo "Usage: $0 code fqdn [force]"; exit; }
[ -e /etc/ubuntu-firstrun -a -z "$3" ] && { echo -n "Already executed: "; cat /etc/ubuntu-firstrun; exit; }

. /etc/profile.d/network-utils.sh

if [ ! -e /tmp/ue.tar.gz ]; then
    wget -O /tmp/ue.tar.gz http://www.cogent-it.com/software/ue/ue.tar.gz
    [ -e /tmp/ue.tar.gz -a -s /tmp/ue.tar.gz ] && tar xf /tmp/ue.tar.gz -C /
    $0 "$@"
    exit
fi
rm -f /tmp/ue.tar.gz

/usr/bin/apt-get update ; /usr/bin/apt-get upgrade
/usr/bin/apt-get install $(grep install /root/packages.log | sed -e 's/^.*install //' | paste -s -d ' ')

I=$(ls -1 /sys/class/net | grep eth | head -1)
IP=$(/sbin/ifconfig $(basename $I) | grep "inet addr" | gawk -F: '{print $2}' | gawk '{print $1}')
BC=$(/sbin/ifconfig $(basename $I) | grep "inet addr" | gawk -F: '{print $3}' | gawk '{print $1}')
NM=$(/sbin/ifconfig $(basename $I) | grep "inet addr" | gawk -F: '{print $4}' | gawk '{print $1}')
NW=$(/usr/bin/ipcalc -nb $IP/$NM | grep ^Network: | perl -pi -e 's/\w+:\s+//')
GW=$(/sbin/route -n | grep "^0.0.0.0" | sed 's/ \+/\t/g' | cut -f 2)
DHCP_RANGE=$(grep dhcp_range /tmp/dhclient.env | uniq | head -1 | cut -d= -f2)

CURIP=$IP
echo Current IP: $CURIP
if [ "$DHCP_RANGE" ]; then
    echo Found DHCP Range: $DHCP_RANGE
else
    echo -n "Cannot look up DHCP Range, what is it? [$NW] "; read DHCP_RANGE
    [ -z "$DHCP_RANGE" ] && DHCP_RANGE="$NW"
fi
if [ $(iplist $DHCP_RANGE | wc -l) -gt 1 ]; then
    iplist $DHCP_RANGE $NW > /tmp/$$
    /usr/bin/nmap -n -sP $NW | grep "Host.* is up " | cut -d' ' -f2 >> /tmp/$$
    IP=$(cat /tmp/$$ | sort | uniq -u | shuf | head -1 ; rm -f /tmp/$$)
else
    IP=$DHCP_RANGE
fi
if [ -z "$IP" ]; then IP=$CURIP; fi
echo New IP: $IP

[ "$I" -a "$IP" -a "$BC" -a "$NM" -a "$GW" ] && perl -pi -e "s/iface $I inet dhcp/iface $I inet static\n\taddress $IP\n\tnetmask $NM\n\tbroadcast $BC\n\tgateway $GW\n/" /etc/network/interfaces
[ "$IP" -a "$2" ] && hostname $IP $2
echo $1 > /etc/groupname
ssh-keygen -t rsa
[ ! -e /root/.ssh/authorized_keys ] && cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys
date +"%Y-%m-%d" > /etc/ubuntu-firstrun

wget -O /tmp/cemosshe.tar.gz http://www.cogent-it.com/software/cemosshe/cemosshe.tar.gz
[ -e /tmp/cemosshe.tar.gz -a -s /tmp/cemosshe.tar.gz ] && tar xf /tmp/cemosshe.tar.gz -C /usr/local/lib
wget -O /tmp/snarsshe.tar.gz http://www.cogent-it.com/software/snarsshe/snarsshe.tar.gz
[ -e /tmp/snarsshe.tar.gz -a -s /tmp/snarsshe.tar.gz ] && tar xf /tmp/snarsshe.tar.gz -C /usr/local/lib
/usr/local/lib/cemosshe/cemosshe.install
/usr/local/lib/snarsshe/snarsshe.install
mkdir -p /backup/snapshots/$1/$2
chmod +t /backup/snapshots/$1/$2
rm -f /tmp/{cemosshe,snarsshe}.tar.gz

echo ; ifconfig
