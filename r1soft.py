#untested

#!/usr/bin/env python
import subprocess
from pathlib import Path
from optparse import OptionParser

repo="
[r1soft]
name=R1Soft Repository Server
baseurl=http://repo.r1soft.com/yum/stable/$basearch/
enabled=1
gpgcheck=0
"

def install(key):
	intall = "yum -y install serverbackup-enterprise-agent"
	addkey="serverbackup-setup --get-key=http://%s"  % key
	getmod="serverbackup-setup --get-module"
	cdprestart="service cdp-agent restart"
	subprocess.call(install, shell=True)
	subprocess.call(addkey, shell=True)
	subprocess.call(getmod, shell=True)
	subprocess.call(cdprestart, shell=True)

def main():
    usage = "usage: python %prog [options] arg"
    parser = OptionParser(usage) 
    parser.add_option("-k", "--keys", dest="key", type=str,
                                        help="set r1soft server ip")                                
    parser.add_option("-r", "--repo", dest="createrepo", default="1",
                                        help="create repo, set to 1/0. defaults to 1")								
    (options, args) = parser.parse_args()
	
	if (options.key is None):
		printf("The R1soft server is not set.
				Please set a server IP.
				")
		subprocess.call("python r1soft.py --help", shell=True)
	else:
		repo="
[r1soft]
name=R1Soft Repository Server
baseurl=http://repo.r1soft.com/yum/stable/$basearch/
enabled=1
gpgcheck=0"
		r1_repo="/etc/yumrepos.d/r1soft.repo"
		ins="echo %s > %s" % (repo, r1_repo)
		subprocess.call(ins, shell=True)
		if (r1_repo.is_file()):
			printf("Installing R1soft")
			install(key)
		else:
			printf("R1soft repo does not exist.")
