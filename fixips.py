#!/usr/bin/env python
# simply pull /etc/domainips from the src server and rename it to /etc/domainips-src
# rsync -avz -e "ssh -p 22" root@192.168.1.100:/etc/domainips /etc/domainips-src
# python fixips.py

# use at your own risk
# and read the above notes 
# before using this script

import subprocess
import os

def main():
        usage = "usage: python %prog [options] arg"
        parser = OptionParser(usage) 
        parser.add_option("-s", "--source", dest="sourceip", type=str,
                                        help="set the source ip address.")                                
        parser.add_option("-p", "--port", dest="sourceport", default="22",
                                        help="set port, defaults to 22 if not set")
        parser.add_option("-i", "--ipfix", dest="fixipVar", default="0",
                                        help="set bit to run fixips.py after successful IP migration") 		
        grabips="rsync -ave 'ssh -p %s' %s:/etc/domainips /etc/domainips-src" % (options.sourceport, options.sourceip)
	subprocess.call(grabips, shell=True)
        if (os.path.isfile("/etc/domainips-src")):
		f=open('/var/cpanel/mainip', 'r')
		mainip=f.read()
		print("setting all cPanel accounts to default shared ip.\n")
		with open('/etc/trueuserdomains') as input_file:
			for i in input_file: # set all cPanel accounts to default main ip
                       		i=i.split()
                       		print("\n%s -> %s\n" % (i[1], mainip))
                       		setip="whmapi1 setsiteip ip=%s user=%s" % (mainip, i[1])
                       		subprocess.call(setip, shell=True)
				logging.info("\n%s -> %s\n", i[1], mainip)
		with open('/etc/domainips-src') as input_file:
                	next(input_file)
                	for i in input_file: # set all dedicated ip cPanel accounts to proper IP
                        	i=i.split()
                        	i[0]=i[0].replace(':','')
                        	i[1]=i[1].replace(' ','')
                        	print("\n%s -> %s\n" % (i[1], i[0]))
                        	setip="whmapi1 setsiteip ip=%s domain=%s" % (i[0], i[1])
                        	subprocess.call(setip, shell=True)
				logging.info("\n%s -> %s\n", i[1], i[0]) # chk json and verify success before logging
        else:
                print('Failed to grab domainips')
if __name__ == "__main__":
    main()
