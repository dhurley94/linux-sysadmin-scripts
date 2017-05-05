#!/bin/bash
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

function !validateIdiocracy
{=
  if [[ ssh $sourceip -p $sourceport -f /root/network-dst.tar.gz ]] -a [[ ssh $sourceip -p $sourceport -f /root/network-src.tar.gz ]]; then
    return 1 # SUCCESS
  else
    return 0 # FAILURE
  fi
  # needs more validation
}

function validateSwap
{=
  ## Josh write this
  ## function generates multiple arrays based on tarballs on dst system
  ## arrays are also generated using current data in network-scripts
  ## if somdething is wrong the script is terminated
  return 1
}

if [[ $# -eq 0 || -z $sourceip ]]; then MENU; fi  # check for existence of required var
if [ -z $sourceport ]; then sourceport=22; fi # apply port 22 if none is set
if [ ! -z $sshkey ]; then setup_sshkey; fi # gen ssh key if not set

$ifcfg = "/etc/sysconfig/network-scripts/ifcfg-eth0"

# remove uuid from dst before created tarballs for source
# centos5 does not need these values to maintain interface names
sed '/HWADDR/d' $ifcfg
sed '/UUID/d' $ifcfg

# create tars and work magic
tar -czf /root/network-dst.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip
ssh root@$sourceip -p $sourceport "tar -czf /root/network-src.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip"

# grab src and refresh domainips if it doesnt exist
rsync -avz -e "ssh -p '$sourceport'" root@$sourceip:/root/network-src.tar.gz /root/
rsync -avz -e "ssh -p '$sourceport'" root@$sourceip:/etc/domainips /etc/domainips-src
rsync -avz -e "ssh -p '$sourceport'" /root/network-dst.tar.gz root@$sourceip:/root/network-dst.tar.gz

if [[ -e /root/network-dst.tar.gz ]] -a [[ -e /root/network-src.tar.gz ]]; then
  if [[]] ## if hwaddr or uuid exist ifcfg, replace with eth0 data
    echo "HWADDR=" ip a l | grep IPADDR $ifcfg | egrep -o '(".*?")' | sed 's/\"//g' -B1 | grep ether | awk {'print$2'}
  else ## add if it doesnt exist in ifcfg
    echo "HWADDR=" ip a l | grep IPADDR $ifcfg | egrep -o '(".*?")' -B1 | grep ether | awk{'print$2'}
  fi
fi

tar -xf network-src.tar.gz -C /
ssh root@$sourceip -p $sourceport "tar -xf network-dst.tar.gz -C /"

if [[ !validateIdiocracy -eq 1 ]] -a [[ validateSwap -eq 1 ]]; then
  echo "Please triple check and verify everything is correct.\nThen restart networking on both systems\n."
	read
  wget post-ipswap.sh
  sh post-ipswap.shift
else
  echo "We were unable to verify consistency of IP swap."
  echo "Please manually validate and proceed with network restart"
fi
