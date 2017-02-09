#!/usr/bin/env python
import subprocess
from optparse import OptionParser
import os

def createEnvironmentBalls(sourceip, sourceport):
	mktar="ssh root@%s -p %s 'tar -czf /root/environment.tar.gz /usr/local/lib/php.ini /etc/my.cnf /var/cpanel/easy/apache/profile/_la st_success.yaml /var/cpanel/easy/apache/profile/_main.yaml'" % (sourceip, sourceport)
	grabballs="rsync -ave 'ssh -p %s' %s:/root/environment.tar.gz /root" % (sourceport, sourceip)
	subprocess.call(mktar, shell=True)
	subprocess.call(grabballs, shell=True)
	if (!os.path.isfile('/root/environment.tar.gz')):
		print("Something went wrong.")
		quit()

def main():
    usage = "usage: python %prog [options] arg"
    parser = OptionParser(usage) 
    parser.add_option("-s", "--source", dest="sourceip", type=str,
                                        help="set the source ip address.")                                
    parser.add_option("-p", "--port", dest="sourceport", default="22",
                                        help="set port, defaults to 22 if not set")	
    (options, args) = parser.parse_args()
    if (options.sourceip is None):
		subprocess.call("python environmentmatch.py --help", shell=True)
		quit()
	else:
		if (os.path.isfile('/root/environment.tar.gz')):
			untarball="tar -xf /root/environment.tar.gz -C /"
			subprocess.call(untarball, shell=True)
			subprocess.call("/scripts/easyapache --default", shell=True)
if __name__ == "__main__":
        main()
