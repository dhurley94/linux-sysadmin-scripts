#!/bin/bash
# In progress IP swap tool for cPanel servers
# works in current state but need to swap hwaddr / uuid in ifcfg
# be careful, and dont run blindly.

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
		r)
			MENU
			flag="r"
			revert
			;;;
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


setup_sshkey() { # generate keys and push to source
	ssh-keygen -t rsa
	ssh-copy-id -p $sourceport root@$sourceip
	sshkey=0
	echo; echo
}

$ifcfg = "/etc/sysconfig/network-scripts/ifcfg-eth0"

# remove uuid from dst before created tarballs for source
sed '/HWADDR/d' $ifcfg 
sed '/UUID/d' $ifcfg

# create tars and work magic
tar -czf /root/network-dst.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip
ssh root@$sourceip -p $sourceport "tar -czf /root/network-src.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip"
rsync -avz -e "ssh -p '$sourceport'" root@$sourceip:/root/network-src.tar.gz /root/
rsync -avz -e "ssh -p '$sourceport'" root@$sourceip:/etc/domainips /etc/domainips-src
rsync -avz -e "ssh -p '$sourceport'" /root/network-dst.tar.gz root@$sourceip:/root/

# remove uuid from dst before created tarballs for source
tar -xf network-src.tar.gz -C /
sed '/HWADDR/d' $ifcfg 
sed '/UUID/d' $ifcfg

echo "Please triple check and verify everything is correct.\nThen restart networking on both systems\n."
read
