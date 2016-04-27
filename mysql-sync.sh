#!/bin/bash

function mysqldump_local()
{
	# local mysql loop
	while true; do
		# create dst dump
		mysqldump > /root/dstgrab.sql
		# check if exists
		if [ -e /root/dstgrab.sql ]; then
			echo "created dst mysql dump"
			break
		fi
	done
	
	echo "please verify this completed successfully before continuing."
	read $wait
}
function mysqldump_remote()
{
	# remote mysql loop
	while true; do
		# create src dump
		ssh root@$ip:$port 'mysqldump > /root/srcgrab.sql'
		echo $pass

	# download src dump
		rsync aux -e 'ssh -p '$port root@$ip:/root/srcgrab.sql /root/
		echo $pass
		
	# check if exists
		if [ -e "/root/srcgrab.sql" ]; then
			echo "succeeded in downloading src mysql dump"
			break
		else
			echo "failed in downloading the sql dump. retrying..."
		fi
	done
	
	echo "please verify this completed successfully before continuing."
	read $wait
}
function mysqlimport()
{
	if [ -e "/root/srcgrab.sql" ]; then
		mysql < srcgrab.sql
	else
		echo "import failed. check error logs before continuing."
		read $wait
	fi
}
while true; do
        echo "input SRC ip address"
        read $ip

        echo "input root password"
        read $pass

        echo "input port number"
        read $port

        echo "please press enter to begin process"
        read $wait

        mysqldump_local
		mysqldump_remote
        mysqlimport
        echo "process has completed. please verify" >> /root/mysqlsync.log
done
