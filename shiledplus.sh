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

PASS = date +%s | sha256sum | base64 | head -c 16;

useradd -p $PASS singlehop
usermod -G wheel singlehop
echo "singlehop"
echo $PASS
