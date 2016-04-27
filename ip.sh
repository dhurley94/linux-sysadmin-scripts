#!/bin/bash
function backup()
{
	# backup local
	cp /etc/hosts /etc/hosts.bak
	cp /etc/ips /etc/ips.bak
	cp /etc/sysconfig/network /etc/sysconfig/network.bak
	cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0.bak
	cp /var/cpanel/mainip /var/cpanel/mainip.bak
	
	# backup remote
	ssh root@$ip:$port 'cp /etc/hosts /etc/hosts.bak'
	echo $pass
	ssh root@$ip:$port 'cp /etc/ips /etc/ips.bak'
	echo $pass
	ssh root@$ip:$port 'cp /etc/sysconfig/network /etc/sysconfig/network.bak'
	echo $pass
	ssh root@$ip:$port 'cp /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0.bak'
	echo $pass
	ssh root@$ip:$port 'cp /var/cpanel/mainip /var/cpanel/mainip.bak'
	echo $pass
	
	echo "verify that these files were backed up successfully"
	read
}

function download()
{
	# replace dst with src files
	rsync aux -e 'ssh -p '$port root@$ip:/etc/hosts /etc/
	echo $pass
	rsync aux -e 'ssh -p '$port root@$ip:/etc/ips /etc/
	echo $pass
	rsync aux -e 'ssh -p '$port root@$ip:/etc/sysconfig/network /etc/sysconfig/
	echo $pass
	rsync aux -e 'ssh -p '$port root@$ip:/etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/
	echo $pass
	rsync aux -e 'ssh -p '$port root@$ip:/var/cpanel/mainip /var/cpanel/
	echo $pass
	
	echo "verify that these files were replaced successfully"
	read
}

while true; do
	echo "input SRC ip address"
	read $ip
	
	echo "input root password"
	read $pass
	
	echo "was this information correct? y/n"
	read $ans
	
	if [$ans == 'y'];then
		backup()
		download()
		break
	fi
done

echo "Manually replace the HW ADDR in /etc/sysconfig/network-scripts/ifcfg-eth0 with the one in ifcfg-eth0.bak"
echo "swap the ip addresses, restart networking on both servers"
echo "reapply vlans"
