#!/bin/bash

cd /usr/src
rm -fv csf.tgz
wget https://download.configserver.com/csf.tgz
tar -xzf csf.tgz
cd csf
if [ -d "/var/cpanel" ]; then
	sh install.cpanel.sh
else
	sh install.sh
fi

curl http://wiki.cryptohost.io/sh_noc_ips > /etc/csf/csf.allow
curl http://wiki.cryptohost.io/sh_noc_ips > /etc/csf/csf.ignore

csf -r

cd /usr/src
rm -fv maldetect-current.tar.gz
wget http://www.rfxn.com/downloads/maldetect-current.tar.gz
tar -xvf maldetect-current.tar.gz
cd maldet-*
sh install.sh

cd ~
