#!/bin/bash

cd /olddrive/etc/

rsync -avHz user* trueuser* domainips secondarymx domainalias valiases vfiltersexim* backupmxhosts proftpd* pure-ftpd* logrotate.conf passwd* group* *domain* *named* wwwacct.conf cpbackup.conf cpupdate.conf quota.conf shadow* *rndc* ips* ipaddrpool* ssl hosts spammer* skipsmtpcheckhosts relay* localdomains remotedomains my.cnf /etc
rsync -avHz /olddrive/usr/local/apache/conf /usr/local/apache
rsync -avHz /olddrive/usr/local/apache/modules /usr/local/apache
rsync -avHz /olddrive/usr/local/apache/domlogs /usr/local/apache
rsync -avHz /olddrive/var/named /var
rsync -avHz /olddrive/usr/local/cpanel /usr/loca
rsync -avHz /olddrive/var/lib/mysql /var/lib
rsync -avHz /olddrive/var/cpanel /var
rsync -avHz /olddrive/usr/share/ssl /usr/share
rsync -avHz /olddrive/var/log/bandwidth /var/log
rsync -avHz /olddrive/var/spool/cron /var/spool
rsync -avHz /olddrive/root/.my.cnf /root

rsync -avHz --progress --exclude=virtfs/ /olddrive/home /

/scripts/upcp --force
/scripts/easyapache
/scripts/initquotas
/scripts/eximup --force
/scripts/mysqlup --force
/etc/init.d/cpanel restart
/scripts/restartsrv_apache
/scripts/restartsrv_exim
/scripts/restartsrv_named
