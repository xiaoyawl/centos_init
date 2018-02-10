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
    curl -Lks4 https://raw.githubusercontent.com/xiaoyawl/centos_init/master/friewall2iptables.sh|bash
    curl -Lks4 https://raw.githubusercontent.com/xiaoyawl/centos_init/master/iptables_init_rules > /etc/sysconfig/iptables
    if [ $1 == "publicnet" ]; then
        sed -i '10s/$/\n-A INPUT                                  -p tcp -m tcp -m state --state NEW -m multiport --dports 22,22992 -m comment --comment "SSH_PORT" -j ACCEPT/' /etc/sysconfig/iptables
        sed -ri '/(172.(30|25)|47.90|119.28.51.253|119.9.95.122|MOA)/d' /etc/sysconfig/iptables
    fi    
    systemctl restart sshd.service iptables.service
}

install_zabbix() {
    curl -Lk4 https://raw.githubusercontent.com/xiaoyawl/centos_init/master/zabbix_install_scripts.sh|bash -x -s net 47.90.33.131
}

install_docker() {
    yum install -y epel-release && yum install -y tmux
    #if ! rpm -ql epel-release >/dev/null 2>&1;then yum install -y tmux epel-release; fi
    curl -Lks4 https://raw.githubusercontent.com/xiaoyawl/centos_init/master/docker-install.sh|bash -s $1        
}

setSELinux() {
    [ -f /etc/sysconfig/selinux ] && { sed -i 's/^SELINUX=.*/#&/;s/^SELINUXTYPE=.*/#&/;/SELINUX=.*/a SELINUX=disabled' /etc/sysconfig/selinux; /usr/sbin/setenforce 0; }
    [ -f /etc/selinux/config ] && { sed -i 's/^SELINUX=.*/#&/;s/^SELINUXTYPE=.*/#&/;/SELINUX=.*/a SELINUX=disabled' /etc/selinux/config; /usr/sbin/setenforce 0; }
}

sync_time() {
    if ! ping ntp.dtops.cc -c1 >/dev/null 2>&1; then
        echo '172.25.0.254   ntp.dtops.cc' >> /etc/hosts
    fi
    [ -x /usr/sbin/ntpdate ] || yum install ntpdate -y
    if grep -q ntpdate /var/spool/cron/root; then sed -i '/ntpdate/d' /var/spool/cron/root; fi
    echo -e "\n*/5 * * * * /usr/sbin/ntpdate -u ntp.dtops.cc >/dev/null 2>&1" >> /var/spool/cron/root
    /usr/sbin/ntpdate -u ntp.dtops.cc
    echo -e "\n=======\n" && cat /var/spool/cron/root
}

add_yum_pulgins() {
    yum install epel-release -y
    if ! which axel 2>/dev/null; then yum install axel -y;fi
    curl -4Lk https://github.com/xiaoyawl/centos_init/raw/master/yum_plugins/axelget.conf > /etc/yum/pluginconf.d/axelget.conf
    curl -4Lk https://github.com/xiaoyawl/centos_init/raw/master/yum_plugins/axelget.py >/usr/lib/yum-plugins/axelget.py
}

disable_ipv6
add_yum_pulgins
sync_time
ssh_iptables $1
install_zabbix
setSELinux
install_docker $2
iptables -nvxL --lin
ss -tnl

