#!/bin/bash

function mysql()
{
	mysqldump > /root/dstgrab.sql
	
	ssh root@$ip 'mysqldump > /root/srcgrab.sql'
	echo $pass
	
	mysql < /root/srcgrab.sql
}