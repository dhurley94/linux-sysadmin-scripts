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
			ifcfg = open("/etc/sysconfig/network-scripts/ifcfg-eth0","r")
			lines = ifcfg.readlines()
			ifcfg = open("/etc/sysconfig/network-scripts/ifcfg-eth0","w")
			for line in lines:
				if line!="^HWADDR" or line!="^UUID":
					ifcfg.write(line)
					
if __name__ == "__main__":
        main()
