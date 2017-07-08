#!/bin/bash
echo "if IP swap was successful run this.\n\nVerify correct default IP in WHM under 'Basic Settings' on dst. press enter"
pause

/usr/local/cpanel/cpkeyclt
service ipaliases reload
/scripts/rebuildhttpdconf
/scripts/restartsrv_named

if [[ -e /etc/domainips-src ]]; then
	wget https://raw.githubusercontent.com/dhurley94/ip-swap/master/fixips.py
	python fixips.py
fi
