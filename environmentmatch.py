# in progress, do not use
# has enviro checking
#!/usr/bin/env python
import subprocess
from optparse import OptionParser
import os

def getphpversion():
	return subprocess.check_output("whmapi1 php_get_handlers")
def getsqlversion():
	return subprocess.check_output("whmapi1 current_mysql_version")

def match(sourceip, sourceport):
	mktar="tar -czf environment.tar.gz /usr/local/lib/php.ini /etc/my.cnf /var/cpanel/easy/apache/profile/_la st_success.yaml /var/cpanel/easy/apache/profile/_main.yaml"
	grabballs="rsync -ave 'ssh -p %s' %s:/root/environment.tar.gz /root" % (sourceport, sourceip)
	if (os.path.isfile("/root/environment.tar.gz")):
		subprocess.call("tar -xf environment.tar.gz -C /", shell=True)
		subprocess.call("/scripts/easyapache --build", shell=True)
	else:
		subprocess.call("python environmentmatch.py --help", shell=True)

def main():
    usage = "usage: python %prog [options] arg"
    parser = OptionParser(usage) 
    parser.add_option("-s", "--source", dest="sourceip", type=str,
                                        help="set the source ip address.")                                
    parser.add_option("-p", "--port", dest="sourceport", default="22",
                                        help="set port, defaults to 22 if not set")	
	parser.add_option("-r", "--dbpass", dest="dbpass", type=str,
                                        help="set mysql root user pass, if set.")
    (options, args) = parser.parse_args()
    if (options.sourceip is None):
		subprocess.call("python environmentmatch.py --help", shell=True)
    else:
		# find a way to run func on src
		# find a better way to do this hardcoded bs
		iniphpdst=getphpversion()
		inimysqldst=getsqlversion()
		#inimysqlsrc=getsqlversion()
		#iniphpsrc=getphpversion()
		match(options.sourceip, options.sourceport)		
		newphpdst=getphpversion()
		newmysqldst=getsqlversion()
		#newphpsrc=getphpversion()
		#newmysqlsrc=getsqlversion()
if __name__ == "__main__":
        main()
