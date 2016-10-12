#!/bin/bash
#########################################################################
# File Name: 123.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: 2016年10月12日 星期三 07时33分27秒
#########################################################################

disable_ipv6() {
        if [[ -n "$(ip a|awk '/inet6/')" ]]; then
                if [[ "7" == "$(awk '{print int(($3~/^[0-9]/?$3:$4))}' /etc/centos-release)" ]]; then
                        if ! awk '/GRUB_CMDLINE_LINUX/' /etc/default/grub|grep 'ipv6.disable=1'; then
                                sed -ri 's/^(GRUB_CMDLINE_LINUX.*)(")$/\1 ipv6.disable=1\2/' /etc/default/grub
                        fi
                        grub2-mkconfig -o /boot/grub2/grub.cfg
                fi
        fi
}

ssh_iptables() {
        sed -ri 's/^#?(Port)\s{1,}.*/\1 22992/' /etc/ssh/sshd_config
        curl -Lks4 onekey.sh/friewall2iptables|bash
        curl -Lks4 onekey.sh/dt_iptables_init > /etc/sysconfig/iptables
        systemctl restart sshd.service
        service iptables restart
}

install_zabbix() {
        curl -Lk4 https://raw.githubusercontent.com/LinuxEA-Mark/zabbix/master/installscripts.sh|bash -x -s net 47.90.33.131
}

install_docker() {
        curl -Lks4 onekey.sh/docker-install|bash -s aufs
}

disable_ipv6
ssh_iptables
install_zabbix
iptables -nvxL --lin
ss -tnl
