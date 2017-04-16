#!/bin/bash
echo "if IP swap was successful run this."
echo "Verify correct default IP in WHM under 'Basic Settings' is the same as"
echo ""
cat /var/cpanel/mainip
echo ""
echo "if it is, press enter"

read

/usr/local/cpanel/cpkeyclt
service ipaliases reload
/scripts/rebuildhttpdconf
/scripts/restartsrv_named

if [[ -e /etc/domainips-src ]]; then
        wget https://raw.githubusercontent.com/dhurley94/ip-swap/master/fixips.py
        python fixips.py
fi
