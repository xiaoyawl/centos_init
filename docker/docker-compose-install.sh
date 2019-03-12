#!/bin/bash
#########################################################################
# File Name: docker-compose-install.sh
# Author: LookBack
# Email: admin#dwhd.org
# Version:
# Created Time: Sun 07 Aug 2016 06:28:43 AM CST
#########################################################################

ComposeUrl=https://github.com/docker/compose/releases
Version=$(curl -Lks "$ComposeUrl"|awk -F'[><]' '$0~/releases\/tag/&&$0!~/rc/{print $3;exit}')
curl -Lk $ComposeUrl/download/$Version/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
