#!/bin/bash
#########################################################################
# File Name: install_softether.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: 2019年03月11日 星期一 05时33分17秒
#########################################################################

mkdir -p /usr/local/softether /scripts
cd /usr/local/softether/

GITHUB_URL="https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases"
FileName="`curl -Lks ${GITHUB_URL}/latest|awk '/<title>Release/{print $2;exit}'`"
FileUrl="https://github.com`curl -Lks ${GITHUB_URL}/latest| awk -F'"' '/href=.*softether-vpnserver-'"$FileName"'.*linux-x64-64bit.tar.gz/{print $2}'`"

clear
echo "Start download SoftEtherVPN Server"
echo -e "Download URL: \n    ${FileUrl}"
sleep 3

curl -Lk ${FileUrl}|tar xz -C ./ --strip-components=1
yes 1 | make
chmod 600 *
chmod 700 vpncmd vpnserver
echo 'export PATH=/usr/local/softether:$PATH' > /etc/profile.d/softether.sh
source /etc/profile.d/softether.sh
vpnserver start

curl -Lks https://raw.githubusercontent.com/xiaoyawl/centos_init/master/Other/auto_remove_vpn_log.sh >/scripts/auto_remove_vpn_log.sh
chmod +x /scripts/auto_remove_vpn_log.sh
echo -e '\n30 00 * * * /scripts/auto_remove_vpn_log.sh\n' >> /var/spool/cron/root && crontab -l