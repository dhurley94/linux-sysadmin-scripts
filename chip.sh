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
	
Example: ./chip.sh -s 192.168.0.20 -p 2222
Example: ./chip.sh -s 192.168.0.20 -k 1
"
	exit 1
}

setup_sshkey() {
	ssh-keygen -t rsa
	ssh-copy-id -p $sourceport root@$sourceip
	sshkey=1
	echo; echo
}

tarchk() {
	if [ -e /root/network-dst.tar.gz ] && [ ssh $sourceip -p $sourceport "-e /root/network-src.tar.gz" ]; then
		return true;
	else
		return false;
	fi
}

revert() {
	echo 'REVERT FUNC'
}

while getopts ":s:p:k:h:" opt; do	
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

if [[ $# -eq 0 || -z $sourceip ]]; then MENU; fi  # check for existence of required var
if [ -z $sourceport ]; then sourceport=22; fi # apply port 22 if none is set
if [ -z $sshkey ]; then setup_sshkey; fi # gen ssh key if not set

ifcfg="/etc/sysconfig/network-scripts/ifcfg-eth0"

if [[ `whoami` != "root" ]] # verifying root login
then
   echo "You'll to be root."
   exit 1
fi



tar -cvzf /root/network-dst.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip 2&1 >> chip.log
ssh root@$sourceip -p $sourceport "tar -cvzf /root/network-dst.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip" 2&1 >> chip.log

if [ tarchk ]; then
	# pull / push ifcfg to servers and sed hwaddr?
	base=(IPADDR GATEWAY NETMASK) # sed replace these strings
	src=() # current source values
	dst=() # current destination values

	n=0
	for i in ${base[@]};  do # building lists
        src[$n]=(ssh root@$sourceip -p $sourceport "grep $i $ifcfg")
        dst[$n]=$(grep $i $ifcfg)
        n=$((n+1))
	done
	
	sed -i "/$destinationip/c\$sourceip/" $ifcfg
	sed -i "/$destinationgateway/c\$sourcegateway/" $ifcfg
		
	ssh root@$sourceip -p $sourceport "cat /etc/ips" > /etc/ips
	ssh root@$sourceip -p $sourceport "cat /var/cpanel/mainip" > /var/cpanel/mainip
	ssh root@$sourceip -p $sourceport "cat /etc/hosts" > /etc/hosts
	ssh root@$sourceip -p $sourceport "cat /etc/sysconfig/network" > /etc/sysconfig/network
	
	scp /etc/sysconfig/network root@$sourceip -p $sourceport:/etc/sysconfig
	
	ssh root@$sourceip -p $sourceport "sed -i '/$sourceip/c\$destinationip/' $ifcfg"
	ssh root@$sourceip -p $sourceport "sed -i '/$sourcegateway/c\$destinationgateway' $ifcfg"
	
else
	echo "Failed. The tarballs were not found. Please restart script"
	exit
fi 
