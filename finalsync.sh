#!/bin/bash
# unfinished and untested

function MENU
{
   echo "
run this on the destination server.
script to perform final MySQL db and public_html sync

PV will be installed via yum to view progress on MySQL import.

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
   echo "You'll need to be root."
   exit 1
fi

if [[ $# -eq 0 || -z $sourceip ]]; then MENU; fi  # check for existence of required var
if [ -z $sourceport ]; then sourceport=22; fi # apply port 22 if none is set
if [ ! -z $sshkey ]; then setup_sshkey; fi # gen ssh key if set

yum install pv -y

if [ ! -e /root/dst-dump.sql ]; then
    mysqldump -u root --all-databases > /root/dst-dump.sql
fi

if [ ! -e /root/src-dump.sql ]; then
	ssh root@$sourceip -p $sourceport "mysqldump -u root --all-databases > /root/src-dump.sql"
	rsync -auv --progress -e "ssh -p $sourceport" root@$sourceip:/root/src-dump.sql
else
	pv /root/src-dump.sql | mysql -u root --all-databases
fi 

# add rsync public_html

printf "the final sync has completed.\n
		please review all databases and public_html directories"