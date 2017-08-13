#!/bin/bash

cd /usr/src
rm -fv csf.tgz
wget https://download.configserver.com/csf.tgz
tar -xzf csf.tgz
cd csf
if [[ -e /var/cpanel ]]; then
    sh install.cpanel.sh
else
    sh install.sh
fi

curl https://raw.githubusercontent.com/dhurley94/ip-swap/master/ships > /etc/csf/csf.allow
curl https://raw.githubusercontent.com/dhurley94/ip-swap/master/ships > /etc/csf/csf.ignore

rm -fv maldetect-current.tar.gz
wget http://www.rfxn.com/downloads/maldetect-current.tar.gz
tar -xvzf maldetect-current.tar.gz
cd maldetect-*
sh install.sh

PASS=`openssl rand -base64 12`

useradd singlehop
echo singlehop:$PASS | chpasswd
usermod -aG wheel singlehop

echo ""
echo "CSF & Maldet installed, but not configured."
echo ""
echo "New Sudo user added"
echo "Please save in Manage notes and provide to client."
echo ""
echo "singlehop / $PASS"
echo ""

cd ~
