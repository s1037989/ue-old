#!/bin/sh

[ -z "$1" ] && { echo "Usage: $0 code fqdn"; exit; }
[ -z "$2" ] && { echo "Usage: $0 code fqdn"; exit; }

. /etc/profile.d/network-utils.sh
apt-get update ; apt-get upgrade
ssh-keygen -t rsa

I=$(ls -1 /sys/class/net | grep eth | head -1)
IP=$(ifconfig $(basename $I) | grep "inet addr" | gawk -F: '{print $2}' | gawk '{print $1}')
BC=$(ifconfig $(basename $I) | grep "inet addr" | gawk -F: '{print $3}' | gawk '{print $1}')
NM=$(ifconfig $(basename $I) | grep "inet addr" | gawk -F: '{print $4}' | gawk '{print $1}')
NW=$(ipcalc -nb $IP/$NM | grep ^Network: | perl -pi -e 's/\w+:\s+//')
GW=$(route -n | grep "^0.0.0.0" | sed 's/ \+/\t/g' | cut -f 2)
DHCP_RANGE=$(grep dhcp_range /tmp/dhclient.env | uniq | head -1 | cut -d= -f2)

CURIP=$IP
echo Current IP: $CURIP
if [ "$DHCP_RANGE" ]; then
	echo Found DHCP Range: $DHCP_RANGE
else
	echo "Cannot look up DHCP Range, what is it? [$NW] "; read DHCP_RANGE
	if [ -z "$DHCP_RANGE" ]; then
		DHCP_RANGE="$NW"
	fi
fi
if [ $(iplist $DHCP_RANGE | wc -l) -gt 1 ]; then
	iplist $DHCP_RANGE $NW > /tmp/$$
	nmap -n -sP $NW | grep "Host.* is up " | cut -d' ' -f2 >> /tmp/$$
	IP=$(cat /tmp/$$ | sort | uniq -u | shuf | head -1 ; rm -f /tmp/$$)
else
	IP=$DHCP_RANGE
fi
if [ -z "$IP" ]; then IP=$CURIP; fi
echo New IP: $IP

[ "$I" -a "$IP" -a "$BC" -a "$NM" -a "$GW" ] && perl -pi -e "s/iface $I inet dhcp/iface $I inet static\n\taddress $IP\n\tnetmask $NM\n\tbroadcast $BC\n\tgateway $GW\n/" /etc/network/interfaces
[ "$IP" -a "$2" ] && hostname $IP $2
echo $1 > /etc/groupname
date +"%Y-%m-%d" > /etc/ubuntu-firstrun

/usr/local/lib/cemosshe/cemosshe
mkdir -p /backup/snapshots
[ ! -e /backup/snapshots/.config ] && echo "NOPARTCHECK=1" > /backup/snapshots/.config
/usr/local/lib/snarsshe/snarsshe /backup/snapshots/$1/$2

echo ; ifconfig
