#!/usr/bin/env python
import subprocess
from optparse import OptionParser
import os
import logging
#import json

def backup(server): # backup all networking related files, iterate w/ src / dst
	logging.info('Creating tarballs for %s', server)
	tarballs="tar -czf /root/%s-network.tar.gz /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network /etc/ips /var/cpanel/mainip /etc/hosts" % (server)
	if (os.path.isfile("/root/%s-network.tar.gz", server)):
		logging.info('tarballs for %s have been created.', server)
		return 1
	else:
		logging.warning('tarballs for %s have failed. exiting now.', server)
		return 0

def removehw(server): # run this before creating tarballs of network files
	ifcfg = open("/etc/sysconfig/network-scripts/ifcfg-eth0","r")
	lines = ifcfg.readlines()
	ifcfg = open("/etc/sysconfig/network-scripts/ifcfg-eth0","w")
	for line in lines:
		if line!="^HWADDR" or line!="^UUID": # doesn't work, only write information that is not uuid / hwaddr in ifcfg
			ifcfg.write(line)
			logging.info('MAC has been removed from %s.', server)
	ifcfg.close()
	# found a 3rd party pkg that will run this function on external server
	# consider using sed

def sshkeys(sourceport, sourceip): # create and apply sshkeys
	genkey="ssh-keygen -t rsa"
	sendkey="ssh-copy-id -p %s %s" % (sourceport, sourceip)
	subprocess.call(genkey, shell=True)
	subprocess.call(sendkey, shell=True)
	# find a way to check if this was successful w/o manual connection

def fixips(sourceport, sourceip): # replaces cPanel ips on new server with old server's
	if (os.path.isfile("/etc/domainips-src")):
		f=open('/var/cpanel/mainip', 'r')
			mainip=f.read()
			print("setting all cPanel accounts to default shared ip.\n")
			with open('/etc/trueuserdomains') as input_file:
				for i in input_file: # set all cPanel accounts to default main ip
                        		i=i.split()
                        		print("\n%s -> %s" % (i[1], mainip))
                        		setip="whmapi1 setsiteip ip=%s user=%s" % (mainip, i[1])
                        		subprocess.call(setip, shell=True)
					logging.info("\n%s -> %s", i[1], mainip)
					print("\n\n\n")
					print("setting dedicated ip cPanel accounts to correct ip.\n")
		with open('/etc/domainips-src') as input_file:
                	next(input_file)
                	for i in input_file: # set all dedicated ip cPanel accounts to proper IP
                        	i=i.split()
                        	i[0]=i[0].replace(':','')
                        	i[1]=i[1].replace(' ','')
                        	print("\n%s -> %s" % (i[1], i[0]))
                        	setip="whmapi1 setsiteip ip=%s domain=%s" % (i[0], i[1])
                        	subprocess.call(setip, shell=True)
				logging.info("\n%s -> %s", i[1], i[0]) # chk json and verify success before logging
	# take json output and parse to log file / verify success

def main():
    logging.basicConfig(filename='ipswap.log',level=logging.DEBUG)
    usage = "usage: python %prog [options] arg"
    parser = OptionParser(usage) 
    parser.add_option("-s", "--source", dest="sourceip", type=str,
                                        help="set the source ip address.")                                
    parser.add_option("-p", "--port", dest="sourceport", default="22",
                                        help="set port, defaults to 22 if not set")
	parser.add_option("-i", "--ipfix", dest="fixipVar", default="0",
                                        help="set bit to run fixips.py after successful IP migration") 										
    (options, args) = parser.parse_args()
    if (options.sourceip is None):
	subprocess.call("python sshkey.py --help", shell=True)
    else:
	grabips="rsync -ave 'ssh -p %s' %s:/etc/domainips /etc/domainips-src" % (sourceport, sourceip)
	subprocess.call(grabips, shell=True)
	# remove existance of old network tarballs from both systems
	# sshkey
	# remove hwaddr/uuid from dst, create tarball, send to src
	# create tarball on src, send to dst, remove hwaddr/uuid
	# perform network conf swap
	# verify files, restart networking, reload ipaliases, rebuildhttpdconf, etc.
	# user input on success, if y then fixips
		
if __name__ == "__main__":
        main()
