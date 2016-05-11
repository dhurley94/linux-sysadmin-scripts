#!/bin/bash

function mysqldumplocal()
{
        # local mysql loop
        if [ -a /root/localgrab.sql ]; then
        	echo "File already exists."
        else
        	mysqldump --all-databases > /root/localgrab.sql
        	if [ -a /root/localgrab.sql ]; then
        		echo "File has been created."
        	fi
        fi

        echo "Press enter to begin source database dump download."
        read wait
}

function mysqldumpremote()
{
	if [ ! -e "/root/srcgrab.sql" ]; then 
		ssh root@$ip -p $port "mysqldump --all-databases > /root/srcgrab.sql"
		rsync -aux -e "ssh -p $port" root@"$ip":/root/srcgrab.sql /root/
			if [ -e "/root/srcgrab.sql" ]; then
				echo "Download of source MySQL dump of source server was successful."
            		else
                		echo "Failed in downloading the sql dump."
                	read wait
            	fi
        fi

        echo "Press enter to continue to import of databases."
        read wait
}
function mysqlimport()
{
        if [ -e "/root/srcgrab.sql" ]; then
            echo "Beginning import of source SQL dump."
            mysql < srcgrab.sql
            echo "Process has completed. Please test and verify nothing broke."
        fi
}

while true; do
        echo "Input source server's ip address."
        read ip
		
        echo "Input source server's SSH port. Press enter for default."
        read port
 
        if [ "$port" = "" ]; then
                port=22
        fi
		
        echo "Press enter to begin."
        read wait

        mysqldumplocal
        mysqldumpremote
        mysqlimport
	echo "MySQL import completed."
        break
done
