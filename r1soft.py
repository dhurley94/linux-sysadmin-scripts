#!/usr/bin/env python
import subprocess
import os
from optparse import OptionParser

#def csf(iscpanel):
#	cd /usr/src
#	wget https://download.configserver.com/csf.tgz
#	tar -xzf csf.tgz
#	cd csf
#	if (iscpanel==1):
#		sh install.cpanel.sh
#	else:
#		sh install.sh 
	
def install(key):
    install = "yum -y install serverbackup-enterprise-agent"
    addkey="serverbackup-setup --get-key=http://%s"  % (key)
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
                                        help="set r1soft server ip.\npython r1soft.py -k 192.168.1.100")
    (options, args) = parser.parse_args()

    if (options.key is None):
        print("The R1soft server is not set.")
        subprocess.call("python r1soft.py --help", shell=True)
    else:
        repo="""
[r1soft]
name=R1Soft Repository Server
baseurl=http://repo.r1soft.com/yum/stable/$basearch/
enabled=1
gpgcheck=0"""
        r1_repo="/etc/yum.repos.d/r1soft.repo"
        r1soft=open(r1_repo, 'w+')
        r1soft.write(repo)
        r1soft.close()
        if (os.path.isfile(r1_repo)):
             print("Installing R1soft")
             install(options.key)
			 print("R1soft has been installed.")
			 print("If you run into issues ensure the kernel up to date.")
        else:
             print("R1soft repo does not exist.")

if __name__ == "__main__":
        main()
