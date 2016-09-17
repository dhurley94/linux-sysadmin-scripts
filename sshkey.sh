#!/bin/bash
# wget http://rizse.tk/scripts/sshkey.sh
# sh sshkey.sh
while true; do
	echo "Input the other servers username."
	read user
	echo "Input server's ip address."
	read ip
	echo "Input server's SSH port. Press enter for default."
	read port
	if [ "$port" = "" ]; then
		port=22
	fi
	printf "\nUser: $user\n$ip:$port\n\n"
	echo 'Are both the IP, Port and User correct? y/n'		
	read wait
	if [ "$wait" == "y" ]; then
		ssh-keygen -t rsa
		ssh-copy-id -p $port $user@$ip
		printf "Testing SSH Keys. \n"
		ssh -p $port $user@$ip
		printf "\n You are now using SSH keys!\n"
		break
	fi
done 
