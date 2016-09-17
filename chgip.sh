#!/bin/bash
# An extremely dirty way to swap network configs between cPanel servers
# This has been tested on 1 production server so far.
while true; do
	### asking for input
	while true; do
		echo "Input source server's ip address."
		read ip
		echo "Input source server's SSH port. Press enter for default."
		read port
		if [ "$port" = "" ]; then
			port=22
		fi
		echo "$ip:$port"
		echo 'Are both the IP and Port correct? y/n'		
		read wait
		if [ "$wait" == "y" ]; then
			clear
			break
		fi
	done
	### Create tarballs on source and destination servers
	### running checks
	echo "Have the source servers root pass ready."
	while true; do
		tar -cvzf /root/network-dst.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip
		printf "tar'd networking on dst.\n"

		ssh root@$ip -p $port "tar -cvzf /root/network-src.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip"	
		printf "tar'd networking on src.\n"
		echo 'press enter to continue'
		read wait
		clear
		#echo 'checking if files exist on both servers.'
		rsync -auv -e "ssh -p $port" root@"$ip":/root/network-src.tar.gz ~
		printf "downloading tar from src.\n"
		
		rsync -auv -e "ssh -p $port" /root/network-dst.tar.gz root@"$ip":~
		echo 'uploading tar to dst.'
		if [ -e "/root/network-src.tar.gz" ]; then
		if [ -e "/root/network-src.tar.gz" ] && [ ssh $ip -p $port "test -e network-dst.tar.gz" ] ; then
			echo 'it do.'
			break
		else
			echo 'Something failed.'
			echo 'Please check that both files were created on both servers.';
			echo $?
		fi
	done
	### let's extract!
	tar -C / -xf /root/network-src.tar.gz
	echo 'extracted tarball on dst.'
	ssh root@$ip -p $port "tar -C / -xf /root/network-dst.tar.gz"
	echo 'extracted tarball on src.'
break
done
printf "\nVerify that these files were replaced on the DST before proceeding.\nManually replace the HW ADDR in /etc/sysconfig/network-scripts/ifcfg-eth0 with the one in ifcfg-eth0.bak\nswap the ip addresses, restart networking on both servers, reapply vlans"
