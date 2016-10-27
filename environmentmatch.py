# in progress, do not use
# script is becoming overly complex for such a simple task.
# possibly remove version checking
#!/usr/bin/env python
import subprocess
from optparse import OptionParser
import os
import MySQLdb

def getphpversion(server, sourceip, sourceport):
	# may not be needed as php version isn't extremely important atm
	try :
		if (server == "dst"):
			dstphp = subprocess.check_output(["php", "-v"])
			return True
		elif (server == "src":
			# remote ssh cmd
			# https://github.com/paramiko/paramiko
			return True
	except:
		return False

def getsqlversion(server, dbpass, sourceip, sourceport): # requires remote root mysql user for src
	# add try / except
	if (server == "dst"):
		db = MySQLdb.connect(host="localhost",
						user="root",
						passwd=dbpass)
	elif (server == "src":
		db = MySQLdb.connect(host=sourceip,
						user="root",
						passwd=dbpass)
		cur=db.cursor()
	version = cur.execute("SELECT VERSION()")
	cur.close()
	return version

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
		match(options.sourceip, options.sourceport)		
if __name__ == "__main__":
        main()
