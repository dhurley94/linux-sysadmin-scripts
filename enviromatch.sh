#!/bin/bash

function MENU
{
   echo "
run this on the destination server.
script to match the PHP / MySQL environments between two servers.

REQUIRED OPTIONS:
	-s <192.168.1.100>
      set the source ip address.
	  
OPTIONS:
	
	-p <2222>
      set the source port, defaults to 22.
	
	-k <1>
      if ssh keys are in use ignore this.
	  -k 1 to generate keys now
	
Ex: ./enviromatch.sh -s 127.0.0.1 -p 2222
Ex: ./enviromatch.sh -s 127.0.0.1 -k 1
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

tar -zcf /root/files-dst.tar.gz /usr/local/lib/php.ini /etc/my.cnf /var/cpanel/easy/apache/profile/_last_success.yaml /var/cpanel/easy/apache/profile/_main.yaml
root@$sourceip -p $sourceport "tar -zcf /root/files.tar.gz /usr/local/lib/php.ini /etc/my.cnf /var/cpanel/easy/apache/profile/_last_success.yaml /var/cpanel/easy/apache/profile/_main.yaml"

rsync -auv -e "ssh -p $sourceport" root@sourceip:/root/files.tar.gz /root

if [ -e /root/files.tar.gz ]; then
	tar -C / xf /root/files.tar.gz
	/scripts/easyapache --build
	echo "Destination server:  " + php -v + " "  + mysql -V
	echo "Source server: " + $(ssh root@$sourceip -p $sourceport "php -v + mysql -V")
	echo ""
	echo "cat match.log"
	printf "\nEnvironment matching has completed. \n"
	
else
	echo "Something went wrong.
		The tarball was not retrieved."
	exit
fi
