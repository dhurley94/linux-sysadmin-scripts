# One Liners
  '''Find all Wordpress and version'''
  locate version.php | xargs grep wp_version |grep -v "\.trash\global\|backup\|virtfs" | grep -v 4.9

  '''Lists all user's followed by their crontab'''
  for i in `ls /var/spool/cron/`; do printf "\n\t crontab for; $i \n" && crontab -l -u  $i; done >> peruser_cron

  '''Makes sql dumps per database in MySQL'''
  for i in `mysql -e "show databases" | sed 's/|//' | sed 's/mysql//'`; do mysqldump --force $i > $i.sql; done
# Migration
## Post IP Swap, cPanel account IP fix
  wget https://raw.githubusercontent.com/dhurley94/linux-sysadmin-scripts/master/fixips.py
  python fixips.py -s 192.168.1.100 -p 2222

## SSH key
  wget https://raw.githubusercontent.com/dhurley94/linux-sysadmin-scripts/master/sshkey.py
  Usage:
  python sshkey.py --help 

## Environment Matching
  Run on src
  *   tar -czf environment.tar.gz /usr/local/lib/php.ini /etc/my.cnf /var/cpanel/easy/apache/profile/_last_success.yaml /var/cpanel/easy/apache/profile/_main.yaml
  Run on dest
  *   rsync -ave 'ssh -p 22' 1.2.3.4:/root/environment.tar.gz /root/environment.tar.gz
  *   tar -xf environment.tar.gz -C /
  If source server is using apache 2.2 you will need to manually set apache 2.4 in easyapache.
  *   /scripts/easyapache

## IP Swap Steps

Due to this process being used more often, I am going to clarify a few things and hopefully make this more streamlined.

  '''Run on SRC'''
  tar -czf /root/network-src.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip /etc/domainips
  
  '''Run on DST'''
  tar -czf /root/network-dst.tar.gz /etc/hosts /etc/ips /etc/sysconfig/network /etc/sysconfig/network-scripts/ifcfg-eth0 /var/cpanel/mainip

The above commands will map “zips” of the networking files cPanel needs in order to properly communicate on the public network. Next  take the two files and download or upload the tarballs to the opposite server.

Now run the src tarball on the destination server, and the dst tarball on the source server. Use the following commands,

  on dst  -  tar -xf network-src.tar.gz -C /
  on src - tar -xf network-dst.tar.gz -C /

On both systems you will need to check the ifcfg-eth0 and verify no HWADDR or UUID value exist,

  vim /etc/sysconfig/network-scripts/ifcfg-eth0

If you plan on using my “ipfix” script, rsync the domainips file now from the source server to the destination server now.

  rsync -avz root@ip:/etc/domainips /etc/domainips-src

Verify everything looks good on both systems, typically checking the “ips” and “ifcfg-eth0” file is enough. Restart networking on each system and reapply the vlan within manage. If one of the systems does not come back online after about 2 minutes, you will need to reach out to our data center for a KVM. Otherwise, Run the following command to update cPanel license keys.

  /usr/local/cpanel/cpkeyclt

'''I recommend running the following commands on the destination server ONLY.'''

  service ipaliases reload
  /scripts/rebuildhttpdconf
  /scripts/restartsrv_named

'''One liner to set all accounts to main shared IP'''
  for i in `cat /etc/domainusers | cut -d: -f1`; do whmapi1 setsiteip ip=`cat /var/cpanel/mainip` user=$i; done

## Obscure Control Panel to cPanel Migration 
  https://forums.cpanel.net/threads/how-to-manually-migrate-from-plesk-ensim-or-directadmin.305091/
# Optimizing Web Server Configurations
## Tweaking / Optimizing httpd.conf
Find out which MPM Client is using<br />
type httpd -l <br />
Output should be similar to this,
 Compiled in modules:
  core.c
  mod_so.c
  prefork.c
  http_core.c
Most common MPM are prefork.c, worker.c, and event.c
[Liquid Web has a good write up on the differences between these MPMs.](https://www.liquidweb.com/kb/apache-mpms-explained/)<br />
Next, let's find the maximum amount of memory httpd is allowed to consume.
  curl https://raw.githubusercontent.com/will-parsons/apachebuddy.pl/master/apachebuddy.pl > apachebuddy.pl
  chmod +x apachebuddy.pl
  ./apachebuddy.pl
Another good script to use for finding per process memory consumption, <br />
  curl https://raw.githubusercontent.com/pixelb/ps_mem/master/ps_mem.py > ps_mem.py
  python ps_mem.py
The next part will take some time messing around with the different values that are set in the /etc/httpd/conf/httpd.conf. After each change restart httpd and run apachebuddy.pl. Try to tweak httpd to use about 30-40% lower than that of the total available server memory (Obviously this depends on whether the server is running applications that also use lots of ram).  [Linode also has a great article for tuning httpd/apache configurations.](https://www.linode.com/docs/websites/apache-tips-and-tricks/tuning-your-apache-server) Good luck!

## Choosing a PHP Handler
  Don't use php-fpm on shared hosting. If they are using php-fpm make sure mpm-itk and prefork.c are enabled.

## Ngintron on cPanel Optimization
Edit /etc/nginx/nginx.conf with this,

  user nginx;
  pid /var/run/nginx.pid;
  
  worker_processes auto;
  worker_rlimit_nofile 65535;
  
  events {
    multi_accept on;
    use epoll;
    worker_connections 65536;
  }
  
  http {
    client_header_buffer_size    1k;
    large_client_header_buffers  4 4k;
    output_buffers   1 32k;
    postpone_output  1460;
    send_timeout           3m;
    keepalive_requests     100;
  
    ## Basic Settings ##
    client_body_buffer_size        128k;
    client_body_timeout            30s; # Use 5s for high-traffic sites
    client_header_timeout          30s; # Use 5s for high-traffic sites
    client_max_body_size           10m;
    keepalive_timeout              3s;
  
    port_in_redirect               off;
    sendfile                       on;
    server_names_hash_bucket_size  512;
    server_name_in_redirect        off;
    server_tokens                  off;
    tcp_nodelay                    on;
    tcp_nopush                     on;
    types_hash_max_size            2048;
  
    ## DNS Resolver ##
    # If in China, enable the OpenDNS entry that matches your network connectivity (IPv4 only or IPv4 & IPv6)
    # OpenDNS (IPv4 & IPv6)
    #resolver                      208.67.222.222 208.67.220.220 [[2620:0:ccd::2](2620:0:ccc::2]);
    # OpenDNS (IPv4 only)
    #resolver                      208.67.222.222 208.67.220.220;
    # Google Public DNS (IPv4 & IPv6)
    #resolver                      8.8.8.8 8.8.4.4 [[2001:4860:4860::8844](2001:4860:4860::8888]);
    # Google Public DNS (IPv4 only) [default]
    resolver                       8.8.8.8 8.8.4.4;
  
    ## Real IP Forwarding ##
    set_real_ip_from 127.0.0.1;
  
    # CloudFlare IPs
    # List from: https://www.cloudflare.com/ips-v4
    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 103.22.200.0/22;
    set_real_ip_from 103.31.4.0/22;
    set_real_ip_from 104.16.0.0/12;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 131.0.72.0/22;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 172.64.0.0/13;
    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 188.114.96.0/20;
    set_real_ip_from 190.93.240.0/20;
    set_real_ip_from 197.234.240.0/22;
    set_real_ip_from 198.41.128.0/17;
    set_real_ip_from 199.27.128.0/21;
    # List from: https://www.cloudflare.com/ips-v6
    set_real_ip_from 2400:cb00::/32;
    set_real_ip_from 2405:8100::/32;
    set_real_ip_from 2405:b500::/32;
    set_real_ip_from 2606:4700::/32;
    set_real_ip_from 2803:f800::/32;
    set_real_ip_from 2c0f:f248::/32;
    set_real_ip_from 2a06:98c0::/29;
  
    # Replace with correct visitor IP
    real_ip_header X-Forwarded-For;
    real_ip_recursive on;
  
    ## MIME ##
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
  
    ## Logging Settings ##
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
  
    ## Caching Settings ##
    open_file_cache max=1000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 5;
    open_file_cache_errors off;
  
    ## Gzip Settings ##
    gzip on;
    gzip_proxied any;
    gzip_buffers 16 8k;
    gzip_comp_level 6;
    gzip_min_length 256;
    gzip_http_version 1.1;
        gzip_types
        application/atom+xml
        application/javascript
        application/json
        application/ld+json
        application/manifest+json
        application/rss+xml
        application/vnd.geo+json
        application/vnd.ms-fontobject
        application/x-font-ttf
        application/x-javascript
        application/x-web-app-manifest+json
        application/x-font-truetype
        application/xhtml+xml
        application/xml
        font/opentype
        font/eot
        font/otf
        image/bmp
        image/svg+xml
        image/x-icon
        text/cache-manifest
        text/css
        text/javascript
        text/plain
        text/vcard
        text/vnd.rim.location.xloc
        text/vtt
        text/x-component
        text/x-cross-domain-policy
        text/x-js
        text/xml;
    gzip_vary on;
  
    # Proxy Settings
    proxy_cache_path /tmp/engintron_dynamic levels=1:2 keys_zone=engintron_dynamic:20m inactive=10m max_size=500m;
    proxy_cache_path /tmp/engintron_static levels=1:2 keys_zone=engintron_static:20m inactive=10m max_size=500m;
    proxy_temp_path /tmp/engintron_temp;
  
    ## Virtual Host Configs ##
  
    ## Client Side Caching ##
    include /etc/nginx/conf.d/*.conf;
        server {
            location ~* .(woff|eot|ttf|svg|mp4|webm|jpg|jpeg|png|gif|ico|css|js)$ {
            expires 30;
        }
    }
  }
# Common
## Disable 2FA on WHM
If you have access to SSH two factor authentication can be disabled and enabled via the CLI using WHM's API,
  whmapi1 twofactorauth_disable_policy
  whmapi1 twofactorauth_enable_policy

## Node.js v7 on cPanel 62+
Node.js is not supported officially by cPanel, but the latest version of Node.js can be installed using the following commands.
  yum install epel-release
  yum install nodejs npm
  npm install -g n
  n stable

## Token Manipulation Error, within RescueBoot
  You may need to mount the drive in read / write
  * mount -o rw,remount /systemroot

  If remounting has not fixed the token error then it is possible the /etc/shadow file is corrupted.
  You can verify this by running the following
  * pwck -r
  If the /etc/shadow file comes back as bad you can rebuild it using the following
  * pwconv
  Running this will rebuild the /etc/shadow file using contents of /etc/passwd
