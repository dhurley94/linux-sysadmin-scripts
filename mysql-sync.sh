#!/bin/bash

function mysqldumplocal()
{
        # local mysql loop
        while true; do
                # create dst dump
                mysqldump > /root/dstgrab.sql
                # check if exists
                if [ -e /root/dstgrab.sql ]; then
                        echo "Destination MySQL dump has been created."
                        break
                fi
        done

        echo "Press enter to continue."
        read wait
}

function mysqldumpremote()
{
        # remote mysql loop
        while true; do
                # create src dump
                ssh root@$ip:$port "mysqldump > /root/srcgrab.sql"
                echo $pass

                # download src dump
                rsync aux -e 'ssh -p "$port"' root@"$ip":/root/srcgrab.sql /root/
                echo $pass

                # check if exists
                if [ -e "/root/srcgrab.sql" ]; then
                        echo "Creation of MySQL dump of source server was successful."
                        break
                else
                        echo "Failed in downloading the sql dump. Enter to retry."
                        read $wait
                fi
        done

        echo "Press enter to continue."
        read $wait
}

function mysqlimport()
{
        if [ -e "/root/srcgrab.sql" ]; then
                echo "Beginning import of source SQL dump."
                mysql < srcgrab.sql
                echo "Process has completed. Please test and verify nothing broke."
                read $wait
        fi
}

while true; do
        echo "Input source server's ip address."
        read ip

        echo "Input source servers root password."
        read -s pass

        echo "Input source server's SSH port. Press enter for default."
        read port

        if [ "$port" = "" ]; then
                port=22
        fi

        echo "Press enter to continue."
        read wait

        mysqldumplocal
                mysqldumpremote

        echo "Process has completed."
done
