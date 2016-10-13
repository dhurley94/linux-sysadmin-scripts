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
               sendkey="ssh-copy-id -p %s %s" % (options.sourceport, options.sourceip)
               subprocess.call(genkey, shell=True)
               subprocess.call(sendkey, shell=True)
if __name__ == "__main__":
        main()
