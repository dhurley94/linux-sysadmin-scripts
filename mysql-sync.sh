#!/bin/bash

function mysqldumplocal()
{
        # local mysql loop
        while true; do
                # create dst dump
                mysqldump --all-databases > /root/dstgrab.sql
                # check if exists
                if [ -e /root/dstgrab.sql ]; then
                        echo "Destination MySQL dump has been created."
                        break
                fi
        done

        echo "Press enter to begin source database dump download."
        read wait
}

function mysqldumpremote()
{
        # remote mysql loop
        while true; do
                # create src dump
                ssh root@$ip -p $port "mysqldump --all-databases > /root/srcgrab.sql"
                echo "Created MySQL dump on source."

                # download src dump
                rsync -aux -e "ssh -p $port" root@"$ip":/root/srcgrab.sql /root/
                echo "Downloaded dump from source."

                # check if exists
                if [ -e "/root/srcgrab.sql" ]; then
                        echo "Download of source MySQL dump of source server was successful."
                        break
                else
                        echo "Failed in downloading the sql dump. Enter to retry."
                        read wait
                fi
        done

        echo "Press enter to continue to import of databases."
        read wait
}

function mysqlimport()
{
        if [ -e "/root/srcgrab.sql" ]; then
                echo "Beginning import of source SQL dump."
                mysql < srcgrab.sql
                echo "Process has completed. Please test and verify nothing broke."
                read wait
        fi
}

# Doesn't work properly. Probably will need to use keys or sshpass
#function passPass()
#{
#	expect "assword:"
#	send $pass"\r"
#	interact
#}

while true; do
        echo "Input source server's ip address."
        read ip
		
        echo "Input source server's SSH port. Press enter for default."
        read port
 
        if [ "$port" = "" ]; then
                port=22
        fi
		
		#echo "Input source servers root password."
        #read -s pass
		
        echo "Press enter to begin destination dump creation."
        read wait

        mysqldumplocal
        mysqldumpremote
        mysqlimport

        break
done
