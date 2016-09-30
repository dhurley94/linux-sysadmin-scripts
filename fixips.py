#!/usr/bin/env python
import subprocess
main(): # whmapi1 setsiteip ip=192.168.4.10 user=username domain=domainname
	mainip=open('/var/cpanel/mainuip', 'r')
	with open('/etc/trueuserdomain') as input_file:
		for i in input_file: # set all cPanel accounts to default main ip
			setip="whmapi1 setsiteip ip=%s user= %s" % (i, mainip)
			print(setip)
		
	with open('/etc/domainips') as input_file:
		for i in input_file: # set all dedicated ip cPanel accounts to proper IP
			input_file.split(':')
			input_file[0].translate(':','')
			setip="whmapi1 setsiteip ip=%s domain= %s" % (input_file[0], input_file[1])
			print(setip)

if __name__ == "__main__":
    main()
