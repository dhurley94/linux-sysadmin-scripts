# cPanel IP swap  
collection of scripts that can help with migrating or managing a new / old cPanel host

## Working Scripts, and brief Description    
**ipfixIP.py**, setings all IP addresses to /var/cpanel/mainip, then pareses /etc/userdomains and sets the proper dedicated IP per cPanel   Domain.  
**cent5-FixIP.py**, works the same as fixIP.py, but is compatible with CentOS5 -> CentOS 5  
**dd.sh, implementation of Singlehop's old dead drive recovery. Recomended not to be used at this time.**  
**Proof of concept for IP swap between cPanel / RHEL based OS.** Please use https://github.com/dhurley94/sysadmin-scripts/blob/master/cpanel_ipswap.py instead.  
**postSwap.sh**, should be ran after completing an IP swap manually or via the script mentioned above.  
**r1softQuick.py** & shieldplus.sh, these scritpts are currently being combined forautomation purposes  
**sshkey.py**, generates SSH key on source server and plcaes it on server2 or otherwise.  
**wp-cronFix.py**, Currently a Work in progress. Will scan entire "updatedb" for version.php if found rewrite wp-config.php fpr akax.php and also update the cronjob automatically. Consider also implemting automated xmlrpc fix if this page is getting hit by random IPs from Chhina.

# Other Projects?  
Creating a PCI compliance script to automatically grab todays security "standards" and apply them to each server accordingly. (cPanel Only)  
