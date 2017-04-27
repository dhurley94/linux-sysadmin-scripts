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
done

wget http://www.rfxn.com/downloads/maldetect-current.tar.gz
tar -xvzf maldetect-current.tar.gz
cd maldet-*
sh install.sh

/usr/sbin/useradd -p `date +%s | sha256sum | base64 | head -c 16; echo;` singlehop
