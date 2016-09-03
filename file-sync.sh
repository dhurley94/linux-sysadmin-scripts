#!/bin/bash

function backup()
{
	# backup local
	#cp /etc/hosts /etc/hosts.bak
	#cp /etc/ips /etc/ips.bak
	#cp /etc/sysconfig/network /etc/sysconfig/network.bak
	#cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0.bak
	#cp /var/cpanel/mainip /var/cpanel/mainip.bak
	
	tar -cvzf /root/network.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip
	
	# backup remote
	ssh root@$ip -p $port "tar -cvzf /root/network.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip"
	#ssh root@$ip -p $port "cp /etc/ips /etc/ips.bak"
	#ssh root@$ip -p $port "cp /etc/sysconfig/network /etc/sysconfig/network.bak"
	#ssh root@$ip -p $port "cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0.bak"
	#ssh root@$ip -p $port "cp /var/cpanel/mainip /var/cpanel/mainip.bak"
	
	echo "All necessary files have been recreated. [filename].bak"
	printf "\n
	/etc/hosts.bak\n
	/etc/ips.bak\n
	/etc/sysconfig/network.bak\n
	/etc/sysconfig/network-scripts/ifcfg-eth0.bak\n
	/var/cpanel/mainip.bak"
}

function download()
{
	# replace dst with src files
	rsync -auv -e "ssh -p $port" root@"$ip":/root/network.tar.gz
	echo "The tarball has been downloaded."
	echo "Press enter to extract the files."
        read wait
        tar -czvf /root/network.tar.gz
	echo "Files have been synced from Source -> Destination"
	
}

while true; do
        echo "Input source server's ip address."
        read ip
		
        echo "Input source server's SSH port. Press enter for default."
        read port
 
        if [ "$port" = "" ]; then
                port=22
        fi
		
        echo "Press enter to begin."
        read wait
	backup
	download
        break
done

echo "Verify that these files were replaced sucessfully before proceeding."
echo "Manually replace the HW ADDR in /etc/sysconfig/network-scripts/ifcfg-eth0 with the one in ifcfg-eth0.bak"
echo "swap the ip addresses, restart networking on both servers"
echo "reapply vlans"
