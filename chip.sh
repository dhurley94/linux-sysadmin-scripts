#!/bin/bash
# In progress IP swap tool for cPanel servers

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
tar -czf /root/network-dst.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip 2&1 >> chip.log
ssh root@$sourceip -p $sourceport "tar -czf /root/network-src.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip" 2&1 >> chip.log

# check things and start the swap
if [ tarchk ]; then
	# pull / push ifcfg to servers and sed hwaddr?
	base=(IPADDR GATEWAY NETMASK HWADDR) # sed replace these strings
	src=() # current source values
	dst=() # current destination values

	n=0
	for i in ${base[@]};  do # building lists
        src[$n]=$(ssh root@$sourceip -p $sourceport "grep $i $ifcfg")
        dst[$n]=$(grep $i $ifcfg)
        n=$((n+1))
	done
	echo "Initial destination before swap: 
		" + ${dst[*]} >> chip.log
		
	echo "Initial source before swap: 
		" + ${src[*]} >> chip.log
	
	rsync -auv -e "ssh -p $sourceport" root@$sourceip:/root/network-src.tar.gz /root
	tar -Cxzf / /root/network-src.tar.gz
	grep $base[3] $ifcfg
	# sed replace hwaddr
	
	#sed -i "/$destinationip/c\$sourceip/" $ifcfg
	#sed -i "/$destinationgateway/c\$sourcegateway/" $ifcfg
		
	#ssh root@$sourceip -p $sourceport "cat /etc/ips" > /etc/ips
	#ssh root@$sourceip -p $sourceport "cat /var/cpanel/mainip" > /var/cpanel/mainip
	#ssh root@$sourceip -p $sourceport "cat /etc/hosts" > /etc/hosts
	#ssh root@$sourceip -p $sourceport "cat /etc/sysconfig/network" > /etc/sysconfig/network
	
	#scp /etc/sysconfig/network root@$sourceip -p $sourceport:/etc/sysconfig
	
	#ssh root@$sourceip -p $sourceport "sed -i '/$sourceip/c\$destinationip/' $ifcfg"
	#ssh root@$sourceip -p $sourceport "sed -i '/$sourcegateway/c\$destinationgateway' $ifcfg"
else
	echo "Failed. The tarballs were not found. Please restart script"
	exit
fi 
