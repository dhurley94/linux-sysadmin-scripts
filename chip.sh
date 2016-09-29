#!/bin/bash
# In progress IP swap tool for cPanel servers
# works in current state but need to swap hwaddr / uuid in ifcfg

function MENU
{
   echo "
run this on the destination server.
script to swap IP addresses between two cPanel servers.

!!this script assumes ifcfg-eth0 is your default interface!!

REQUIRED OPTIONS:
	-s <192.168.1.100>
      set the source ip address.
	  
OPTIONS:
	
	-p <2222>
      set the source port, defaults to 22.
	
	-k <1>
      if ssh keys are in use ignore this.
	  -k 1 to generate keys now
	
Ex: ./chip.sh -s 127.0.0.1 -p 2222
Ex: ./chip.sh -s 127.0.0.1 -k 1
"
	exit 1
}

setup_sshkey() { # generate keys and push to source
	ssh-keygen -t rsa
	ssh-copy-id -p $sourceport root@$sourceip
	sshkey=0
	echo; echo
}

tarchk() { # verify tarballs exist on source & destination
	if [ -e /root/network-dst.tar.gz ] && [ ssh $sourceip -p $sourceport "-e /root/network-src.tar.gz" ]; then return true; else return false; fi
}

revert() {
	echo 'REVERT FUNC'
	# store initial values in a text file
	# restore with them?
	# ping 8.8.8.8 after 120s revert settings?
}

while getopts ":s:p:k:h" opt; do
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

if [[ `whoami` != "root" ]] # verifying root login
then
   echo "You'll to be root."
   exit 1
fi

if [[ $# -eq 0 || -z $sourceip ]]; then MENU; fi  # check for existence of required var
if [ -z $sourceport ]; then sourceport=22; fi # apply port 22 if none is set
if [ ! -z $sshkey ]; then setup_sshkey; fi # gen ssh key if not set

ifcfg="/etc/sysconfig/network-scripts/ifcfg-eth0"

# create tars
tar -czf /root/network-dst.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip
ssh root@$sourceip -p $sourceport "tar -czf /root/network-src.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip"

# check things and start the swap
if [ tarchk ]; then
	dst=grep HWADDR $ifcfg
	src=ssh root@$sourceip -p $sourport "grep HWADDR $ifcfg"
	
	rsync -auv -e "ssh -p $sourceport" root@$sourceip:/root/network-src.tar.gz /root
	tar -xf /root/network-src.tar.gz -C /
	ssh root@$sourceip "tar -xf /root/network-dst.tar.gz -C /"
	
	
	cat $ifcfg | sed '/HWADDR/d'
	ssh root@$sourceip "cat $ifcfg | sed '/HWADDR/d"
else
	echo "Failed. The tarballs were not found. Please restart script"
	exit
fi 
