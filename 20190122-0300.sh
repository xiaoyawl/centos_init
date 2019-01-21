#!/bin/bash
#########################################################################
# File Name: 20190122-0300.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: Mon Jan 21 11:12:55 2019
#########################################################################

#内核修改
if grep -q 'net.ipv4.conf.all.rp_filter' /etc/sysctl.conf 2>/dev/null; then
	sed -ri 's/^.?(net.ipv4.conf.all.rp_filter).*/\1 = 2/' /etc/sysctl.conf
else
	echo 'net.ipv4.conf.all.rp_filter = 2' >> /etc/sysctl.conf
fi
sysctl -p


ipnu=($(ip addr | awk '$1=="inet" && $NF!="lo" && $NF!~"docker" {print $NF"="$2}'|awk -F'=' '!a[$1]++{print $1}'))
if [[ "${#ipnu[@]}" == "2" ]]; then
	for i in ${ipnu[@]};do
		if grep -q 'METRIC' /etc/sysconfig/network-scripts/ifcfg-$i 2>/dev/null; then
			if [ '$i' = 'eth0' ]; then
				sed -ri 's/^.?(METRIC).*/\1=100/' /etc/sysconfig/network-scripts/ifcfg-$i
			else
				sed -ri 's/^.?(METRIC).*/\1=1000/' /etc/sysconfig/network-scripts/ifcfg-$i
			fi
		else
			if [ '$i' = 'eth0' ]; then
				echo 'METRIC=100' >> /etc/sysconfig/network-scripts/ifcfg-$i
			else
				echo 'METRIC=1000' >> /etc/sysconfig/network-scripts/ifcfg-$i
			fi
		fi
	done
else
	echo 'METRIC=100' >> /etc/sysconfig/network-scripts/ifcfg-eth0
fi

if systemctl list-unit-files --state=enabled| grep -q 'NetworkManager.service'; then 
	systemctl disable NetworkManager.service && systemctl stop NetworkManager.service
fi
systemctl restart network
