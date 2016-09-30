#!/usr/bin/env python
# working on transferring these scripts to python

import subprocess
from optparse import OptionParser

parser = OptionParser()

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
	subprocess.call([genkey], shell=True)
