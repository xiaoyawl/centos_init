#!/bin/bash
#########################################################################
# File Name: /scripts/auto_remove_vpn_log.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: 2019年03月11日 星期一 05时27分20秒
#########################################################################

find /usr/local/softether/ -type f -name '*.log' -mtime +7 -exec rm -f {} \;