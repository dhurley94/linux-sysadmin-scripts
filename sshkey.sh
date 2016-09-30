#!/bin/bash

function MENU
{
   echo "
script to ssh key two seperate systems.

REQUIRED OPTIONS:
	-s <192.168.1.100>
      set the source ip address.
	  
	-u <root>
      user you want the public key on, defaults to root
	  
OPTIONS:
	-p <2222>
      set the source port, defaults to 22.
	
Ex: ./sshkey.sh -s 127.0.0.1 -u frank -p 2222
"
	exit 1
}

setup_sshkey() { # generate keys and push to source
	cat ~/.ssh/id_rsa.pub | ssh $user@$sourceip -p $sourceport "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
}

while getopts ":s:p:u:k:h" opt; do
	case $opt in		
		s)
			sourceip=$OPTARG
			flag="s"
			;;
		p)
			sourceport=$OPTARG
			flag="p"
			;;
		u)
			user=$OPTARG
			flag="u"
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
if [ -z "$sourceport" ]; then sourceport=22; fi # apply port 22 if none is set
if [ -z "$user" ]; then user="root"; fi
if [ -e /etc/redhat-release ]; then
	setup_sshkey
	printf "\nTesting SSH Keys. \n"
	ssh $user@$sourceip -p $sourceport
	printf "\nYou are now using SSH keys!\n"
	exit
fi
