#!/usr/bin/env python
# simply pull /etc/domainips from the src server and rename it to /etc/domainips-src
# mv /etc/domainips /etc/domainips-src
# python fixips.py

# use at your own risk
# and read the above notes 
# before using this script

import subprocess
def main():
        f=open('/var/cpanel/mainip', 'r')
        mainip=f.read()
        print("setting all cPanel accounts to default shared ip.\n")
        with open('/etc/trueuserdomains') as input_file:
                for i in input_file: # set all cPanel accounts to default main ip
                        i=i.split()
                        print("\n%s -> %s" % (i[1], mainip))
                        setip="whmapi1 setsiteip ip=%s user=%s" % (mainip, i[1])
                        subprocess.call(setip, shell=True)
        print("\n\n\n")
        print("setting dedicated ip cPanel accounts to correct ip.\n")
        with open('/etc/domainips-src') as input_file:
                next(input_file)
                for i in input_file: # set all dedicated ip cPanel accounts to proper IP
                        i=i.split()
                        i[0]=i[0].replace(':','')
                        i[1]=i[1].replace(' ','')
                        print("\n%s -> %s" % (i[1], i[0]))
                        setip="whmapi1 setsiteip ip=%s domain=%s" % (i[0], i[1])
                        subprocess.call(setip, shell=True)

if __name__ == "__main__":
    main()
