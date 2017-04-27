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
