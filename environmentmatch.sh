function tarballs()
{
	tar -zcf /root/files.tar.gz /usr/local/lib/php.ini /etc/my.cnf /var/cpanel/easy/apache/profile/_last_success.yaml /var/cpanel/easy/apache/profile/_main.yaml
	ssh root@$ip -p $port "tar -zcf /root/files.tar.gz /usr/local/lib/php.ini /etc/my.cnf /var/cpanel/easy/apache/profile/_last_success.yaml /var/cpanel/easy/apache/profile/_main.yaml"
	echo "Verifying if files exist."
	ls -alh /root/files.tar.gz
	ssh root@$ip -p $port "ls -alh /root/files.tar.gz"
}

function verifyVer()
{
	echo "Checking PHP / MySQL versions \n"
	echo "Source: \n"
	php -v && echo '\n' && mysql -V && echo '\n'
	echo "Destination: \n"
	ssh root@$ip -p $port "php -v && echo '\n' && mysql -V && echo '\n'"
}

while true; do
	echo "This script should be ran on the destination server."
    echo "Input source server's ip address."
    read ip
		
    echo "Input source server's SSH port. Press enter for default."
    read port
 
    if [ "$port" = "" ]; then
        port=22
    fi
		
	echo "Press enter to begin tar extract"
    read wait
	tarballs
	cd /root/ && mkdir migrate_conf && tar -zxvf files.tar.gz -C migrate_conf/ && cd /root/migrate_conf && mv etc/my.cnf /etc/my.cnf && mv usr/local/lib/php.ini /usr/local/lib/php.ini && mv /var/cpanel/easy/apache/profile/_main.yaml /var/cpanel/easy/apache/profile/_main.yaml && mv /var/cpanel/easy/apache/profile/_last_success.yaml /var/cpanel/easy/apache/profile/_last_success.yaml
    /scripts/easyapache
	verifyVer
	break
done
