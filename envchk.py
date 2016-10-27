# in progress, do not use
# script w/ php, db version chk removed
#!/usr/bin/env python
import subprocess
from optparse import OptionParser
import os
import logging

def match(sourceip, sourceport):
	mktar="tar -czf environment.tar.gz /usr/local/lib/php.ini /etc/my.cnf /var/cpanel/easy/apache/profile/_la st_success.yaml /var/cpanel/easy/apache/profile/_main.yaml"
	grabballs="rsync -avze 'ssh -p %s' %s:/root/environment.tar.gz /root" % (sourceport, sourceip)
	if (os.path.isfile("/root/environment.tar.gz")):
		logging.info("tarball has successfully been downloaded to dst.")
		return True

def main():
    logging.basicConfig(filename='envchk.log',level=logging.DEBUG)
    usage = "usage: python %prog [options] arg"
    parser = OptionParser(usage) 
    parser.add_option("-s", "--source", dest="sourceip", type=str,
                                        help="set the source ip address.")                                
    parser.add_option("-p", "--port", dest="sourceport", default="22",
                                        help="set port, defaults to 22 if not set")	
    (options, args) = parser.parse_args()
    if (options.sourceip is None):
		subprocess.call("python environmentmatch.py --help", shell=True)
    else:
		match(options.sourceip, options.sourceport)
		if (match()):
			logging.info("uncompressing environment configs.")
			subprocess.call("tar -xf environment.tar.gz -C /", shell=True)
			logging.info("building easyapache.")
			subprocess.call("/scripts/easyapache --build", shell=True)
			logging.info("needful has been completed.")
			print("\n2ez4\n2sbz\n")
		else:
			print("\nFailed to create tarball.")
			logging.info("unable to needful.")
		
if __name__ == "__main__":
        main()
