#!/bin/bash
#########################################################################
# File Name: friewall2iptables.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: Tue 24 May 2016 08:05:13 AM CST
#########################################################################

systemctl mask firewalld
systemctl stop firewalld
yum -y install iptables-devel iptables-services iptables
systemctl enable iptables
systemctl start iptables
