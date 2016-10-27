#!/usr/bin/env python
import subprocess
from optparse import OptionParser
def main():
        usage = "usage: python %prog [options] arg"
        parser = OptionParser(usage)
        parser.add_option("-s", "--source", dest="sourceip", type=str,
                                        help="set the source ip address.")                                
        parser.add_option("-p", "--port", dest="sourceport", default="22",
                                        help="set port, defaults to 22 if not set")                                                         
        (options, args) = parser.parse_args()
        if (options.sourceip is None):
               subprocess.call("python sshkey.py --help", shell=True)
        else:
               genkey="ssh-keygen -t rsa"
               setperm=""ssh root@%s -p %s "mkdir ~/.ssh && chmod 700 ~/.ssh && chmod 600 .ssh/authorized_keys""" % (options.sourceip, options.sourceport)
               sendkey=""cat ~/.ssh/id_rsa.pub | ssh root@%s -p %s "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys""" % (options.sourceip, options.sourceport)
               #sendkey="ssh-copy-id -p %s %s" % (options.sourceport, options.sourceip)
               subprocess.call(setperm, shell=True)
               subprocess.call(genkey, shell=True)
               subprocess.call(sendkey, shell=True)
               access="ssh root@%s -p %s " % (options.sourceip, options.sourceport)
if __name__ == "__main__":
        main()
