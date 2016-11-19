#!/usr/bin/env python
import subprocess
from optparse import OptionParser
import os

def exists_remote(host, path, port):
    status = subprocess.call(
        ['ssh', host, '-p', port, 'test -f {}'.format(pipes.quote(path))])
    if status == 0:
        return True
    if status == 1:
        return False
    raise Exception('SSH failed')

def backup(server): # backup all networking related files, iterate w/ src / dst
	tarballs="tar -czf /root/%s-network.tar.gz /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network /etc/ips /var/cpanel/mainip /etc/hosts" % (server)
	if (os.path.isfile("/root/%s-network.tar.gz", server)):
		print "\nFile $s-network.tar.gz already exists.\n" % (server)
	else:
		subprocess.call(tarballs, shell=True)

def removehw(): # rewrites ifcfg w/o hwaddr/uuid
	ifcfg = open("/etc/sysconfig/network-scripts/ifcfg-eth0","r+")
	lines = ifcfg.readlines()
	for line in lines:
		if ("HWADDR" not in line or "UUID" not in line):
			ifcfg.write(line)
	ifcfg.close()

def sshkeys(sourceport, sourceip): # create and apply sshkeys
	genkey="ssh-keygen -t rsa"
	sendkey="ssh-copy-id -p %s %s" % (sourceport, sourceip)
	subprocess.call(genkey, shell=True)
	subprocess.call(sendkey, shell=True)
	# find a way to check if this was successful w/o manual connection

def main():
    usage = "usage: python %prog [options] arg"
    parser = OptionParser(usage) 
    parser.add_option("-s", "--source", dest="sourceip", type=str,
                                        help="set the source ip address.")                                
    parser.add_option("-p", "--port", dest="sourceport", default="22",
                                        help="set port, defaults to 22 if not set")
    				
    (options, args) = parser.parse_args()
    if (options.sourceip is None):
        subprocess.call("python sshkey.py --help", shell=True)
    else:
        sshkey(options.sourceport, options.sourceip)
        backup("dst-dst")
        removehw()
        backup("dst-src")
        subprocess.call('ssh', options.sourceip, '-p', options.sourceport, "tar -czf /root/src-src-network.tar.gz /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network /etc/ips /var/cpanel/mainip /etc/hosts")
        if exists_remote(options.sourceip, 'src-src-network.tar.gz', options.port)
            subprocess.call('tar -xf src-src-network.tar.gz -C /')
            removehw()
          
	# sshkey
	# remove hwaddr/uuid from dst, create tarball, send to src
	# create tarball on src, send to dst, remove hwaddr/uuid
	# perform network conf swap
	# verify files, restart networking, reload ipaliases, rebuildhttpdconf, etc.
		
if __name__ == "__main__":
        main()
