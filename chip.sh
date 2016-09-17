#!/bin/bash

function MENU
{
   echo "
Script to swap IP addresses between two cPanel servers.
REQUIRED OPTIONS:
	-s
      set the source ip address.
	  
OPTIONS:
	
	-p
      set the source port, defaults to 22 if no input.
	
	-k 
      are ssh keys in use? set 1 if yes. defaults to ssh key creation
	
Example: ./chip.sh -sp 192.168.0.20 2222
Example: ./chip.sh -sk 192.168.0.20 1
"
	exit 1
}

setup_sshkey() {
	ssh-keygen -t rsa
	ssh-copy-id -p $sourceport root@$sourceip
	echo; echo
}

tarchk() {
	if [ -e /root/network-dst.tar.gz ] && [ ssh $sourceip -p $sourceport "test -e network-src.tar.gz" ]; then
		return true;
	else
		return false;
	fi
}

revert() {
	echo 'REVERT FUNC'
}

ipswap() {
	echo 'IPSWAP FUNC'
	if [ $credchk -eq 1 ] && [ tarballchk ]; then
		sed -i "/$destinationip/c\$sourceip/" $ifcfg
		sed -i "/$destinationgateway/c\$sourcegateway/" $ifcfg
	
		ssh root@$sourceip -p $sourceport "cat /etc/ips" > /etc/ips
		ssh root@$sourceip -p $sourceport "cat /var/cpanel/mainip" > /var/cpanel/mainip
		ssh root@$sourceip -p $sourceport "cat /etc/hosts" > /etc/hosts
		ssh root@$sourceip -p $sourceport "cat /etc/sysconfig/network" > /etc/sysconfig/network
	
		scp /etc/sysconfig/network root@$sourceip -p $sourceport:/etc/sysconfig
	
		ssh root@$sourceip -p $sourceport "sed -i '/$sourceip/c\$destinationip/' $ifcfg"
		ssh root@$sourceip -p $sourceport "sed -i '/$sourcegateway/c\$destinationgateway' $ifcfg"
	fi
}

while getopts ":a:r:s:" opt; do	
	case $opt in		
		s)
			sourceip=$OPTARG
			flag="s"
			;;
		p)
			sourceport=$OPTARG
			flag="p"
			;;
		k)
			sshkey=$OPTARG
			flag="k"
			;;
		h)
			MENU
			flag="h"
			;;
		\?) echo "invalid option: -$OPTARG"; echo; MENU;;
		:) echo "option -$OPTARG requires an argument."; echo; MENU;;
	esac
done

if [[ $# -eq 0 || -z $sourceip ]]; then echo MENU; fi  # check for existence of required var
if [ -z $sourceport ]; then sourceport=22; fi
if [ -z $sshkey ]; then setup_sshkey; fi

if [[ `whoami` != "root" ]]
then
   echo "You'll to be root."
   exit 1
fi

#tar -cvzf /root/network-dst.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip
#ssh root@$sourceip -p $sourceport "tar -cvzf /root/network-dst.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip"

#if [ tarchk ]; then
#	ifcfg = "/etc/sysconfig/network-scripts/ifcfg-eth0"
#	info[0] = "IPADDR"
#	info[1] = "GATEWAY"
#	info[2] = "NETMASK"

#	src[]
#	dst[]
	
#	for i in 2; do
#		dst[i] = ssh root@$sourceip -p $sourceport "grep info[i] $ifcfg"
#		src[i] = grep info[i] $ifcfg
#	done
#fi
