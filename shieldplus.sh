#!/bin/bash

if [[ ! -e /usr/sbin/csf ]]; then
    cd /usr/src
    rm -fv csf.tgz
    /usr/bin/wget https://download.configserver.com/csf.tgz
    tar -xzf csf.tgz
    cd csf
    if [[ -e /var/cpanel ]]; then
        sh install.cpanel.sh
        /usr/bin/curl https://raw.githubusercontent.com/dhurley94/ip-swap/master/csf.conf > /etc/csf/csf.conf
    else
        sh install.sh
        /usr/bin/curl https://raw.githubusercontent.com/dhurley94/ip-swap/master/csf.conf > /etc/csf/csf.conf
    fi
else 
    echo "CSF already installed."
fi

/usr/bin/curl https://raw.githubusercontent.com/dhurley94/ip-swap/master/ships >> /etc/csf/csf.allow
/usr/bin/curl https://raw.githubusercontent.com/dhurley94/ip-swap/master/ships >> /etc/csf/csf.ignore

if [[ ! -e /usr/local/sbin/maldet ]]; then
    rm -fv maldetect-current.tar.gz
    /usr/bin/wget http://www.rfxn.com/downloads/maldetect-current.tar.gz
    tar -xvzf maldetect-current.tar.gz
    cd maldetect-*
    sh install.sh
else
    echo "Maldet already installed."
    /usr/local/sbin/maldet -u
    if [[ -e /var/cpanel ]]; then
        /usr/local/cpanel/3rdparty/bin/freshclam
    fi
fi

sed -i '/Port 22/c\Port 2222' /etc/ssh/sshd_config
sed -i '/PermitRootLogin yes/c\PermitRootLogin no' /etc/ssh/sshd_config

service sshd restart

PASS=`openssl rand -base64 12`

useradd singlehop
echo singlehop:$PASS | chpasswd
usermod -aG wheel singlehop

echo ""
echo "CSF & Maldet installed, but not configured."
echo ""
echo "New Sudo user added"
echo "Please update SSH port in Manage to 2222."
echo "Update Manage notes and client with sudoer."
echo ""
echo "singlehop / $PASS"
echo ""

cd ~
