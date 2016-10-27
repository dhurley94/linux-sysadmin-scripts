#!/usr/bin/env python
import subprocess
import os
from optparse import OptionParser

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
                                        help="set r1soft server ip")
    parser.add_option("-r", "--repo", dest="createrepo", default="1",
                                        help="create repo, set to 1/0. defaults to 1")
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
        else:
             print("R1soft repo does not exist.")

if __name__ == "__main__":
        main()
