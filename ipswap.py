#doesn't work

#!/usr/bin/env python
import subprocess
from optparse import OptionParser
import os

def removehw():
	ifcfg = open("/etc/sysconfig/network-scripts/ifcfg-eth0","r")
	lines = ifcfg.readlines()
	ifcfg = open("/etc/sysconfig/network-scripts/ifcfg-eth0","w")
	for line in lines:
		if line!="^HWADDR" or line!="^UUID": # doesn't work, only write lines that do not contain HWADDR / UUID
			ifcfg.write(line)	

def sshkeys(sourceport, sourceip):
	genkey="ssh-keygen -t rsa"
    sendkey="ssh-copy-id -p %s %s" % (sourceport, sourceip)
    subprocess.call(genkey, shell=True)
    subprocess.call(sendkey, shell=True)

def fixips(sourceport, sourceip):
	grabips="rsync -ave 'ssh -p %s' %s:/etc/domainips /etc/domainips-src" %s (sourceip, sourceport)
	subprocess.call(grabips, shell=True)
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

def main():
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
			# do a thing
					
if __name__ == "__main__":
        main()
