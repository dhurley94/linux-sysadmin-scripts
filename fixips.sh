#!/usr/bin/env python
# untested
import os
import subprocess
main():
	if os.path.exists('/etc/redhat-release'):
		try:
			mainip=open('/var/cpanel/mainuip', 'r')
			with open('/etc/trueuserdomain') as input_file:
				for i, line in enumerate(input_file): # set all cPanel accounts to default main ip
					setip="/usr/local/cpanel/bin/setsiteip -u %s %s" % (i, mainip)
					print(setip)
				#subprocess.call(setip, shell=True)
			print("\nAll user accounts are now using the shared IP.")
		except IOError:
			print("\nFailed, something went from.")
	#with open('/etc/trueuserdomain') as input_file:
	#	for i, line in enumerate(input_file): # set all dedicated ip cPanel accounts to proper IP
	#		setip="/usr/local/cpanel/bin/setsiteip -u %s %s" % (i, mainip)
	#		print(setip)
	#		subprocess.call(setip, shell=True)
