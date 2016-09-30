#!/usr/bin/env python
import subprocess
from optparse import OptionParser
def main():
	usage = "usage: %prog [options] arg"
	parser = OptionParser(usage)
	parser.add_option("-s", "--source", dest="sourceip",
					help="set the source ip address.")				  
	parser.add_option("-p", "--port", dest="sourceport", default="22"
					help="set port, defaults to 22 if not set")				  
	parser.add_option("-u", "--user", dest="user", default="root"				  
					help="set username to be ssh keyed, defaults to root")				  
	(options, args) = parser.parse_args()	
	if (options.sourceip is None):
		print("You will need to set the source IP");
	else 
		genkey="cat ~/.ssh/id_rsa.pub | ssh %s@%s -p %s 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'" % (options.user, options.sourceip, options.sourceport)
		perms="ssh root@%s -p %s 'chmod 700 .ssh; chmod 640 /root/.ssh/authorized_keys" % (options.user, options.sourceip, options.sourceport)
		subprocess.call([genkey], shell=True)
		subprocess.call([perms], shell=True)		
if __name__ == "__main__":
    main()
