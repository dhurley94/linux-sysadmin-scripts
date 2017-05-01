#!/bin/bash
# be careful, and dont run blindly.

# replace mac rather than removing. removing hwaddr on centos7 apparently changes the interface name to new convention
#MACID=`ip a l | grep <eth0ip> -B1 | grep ether | awk {'print$2'}`
#if sed -i -e 's/.*HWADDR.*/HWADDR=${MACID}/' /etc/sysconfig/blahblah; then
#echo "Yay we replaced the macid"
#else
#echo "HWADDR=${MACID}" >> /etc/sysconfig/blahblah
#echo "HWADDR didn't exist so I added it"
#fi

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
   echo "You're not root."
   exit 1
fi

if [[ $# -eq 0 || -z $sourceip ]]; then MENU; fi  # check for existence of required var
if [ -z $sourceport ]; then sourceport=22; fi # apply port 22 if none is set
if [ ! -z $sshkey ]; then setup_sshkey; fi # gen ssh key if not set

$ifcfg = "/etc/sysconfig/network-scripts/ifcfg-eth0"

# remove uuid from dst before created tarballs for source
sed '/HWADDR/d' $ifcfg 
sed '/UUID/d' $ifcfg

# create tars and work magic
tar -czf /root/network-dst.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip
ssh root@$sourceip -p $sourceport "tar -czf /root/network-src.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip"
rsync -avz -e "ssh -p '$sourceport'" root@$sourceip:/root/network-src.tar.gz /root/
rsync -avz -e "ssh -p '$sourceport'" root@$sourceip:/etc/domainips /etc/domainips-src
rsync -avz -e "ssh -p '$sourceport'" /root/network-dst.tar.gz root@$sourceip:/root/network-dst.tar.gz

if [[ -e /root/network-dst.tar.gz ]] -a [[ /root/network-src.tar.gz ]]; then
	# remove uuid from dst before created tarballs for source
	ssh root@$sourceip -p $sourceport "tar -xf network-dst.tar.gz -C /"
	tar -xf network-src.tar.gz -C /"
	sed '/HWADDR/d' $ifcfg 
	sed '/UUID/d' $ifcfg
	echo "Please triple check and verify everything is correct.\nThen restart networking on both systems\n."
	read
else
	echo "ha broke"
fi
