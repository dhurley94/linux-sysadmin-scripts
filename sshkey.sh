#!/bin/bash
while true; do
	echo "Input source server's ip address."
	read ip
	echo "Input source server's SSH port. Press enter for default."
	read port
	if [ "$port" = "" ]; then
		port=22
	fi
	echo "$ip:$port"
	echo 'Are both the IP and Port correct? y/n'		
	read wait
	if [ "$wait" == "y" ]; then
		ssh-keygen -t rsa
		cat ~/.ssh/id_rsa.pub | ssh root@$ip:$port "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"
		break
	fi
done 
