#!/usr/bin/env python
# simply pull /etc/trueuserdomains & /etc/domainips from the src server.
# this has not been tested on a production server
# python fixips.py
import subprocess
def main():
        f=open('/var/cpanel/mainip', 'r')
        mainip=f.read()
        with open('/etc/trueuserdomains') as input_file:
                for i in input_file: # set all cPanel accounts to default main ip
                        i=i.split()
                        setip="whmapi1 setsiteip ip=%s user=%s" % (mainip, i[1])
                        print(setip)
                        subprocess.call(setip, shell=True)
        print("\n\n\n")
        with open('/etc/domainips') as input_file:
                next(input_file)
                for i in input_file: # set all dedicated ip cPanel accounts to proper IP
                        i=i.split()
                        print(i)
                        i[0]=i[0].replace(':','')
                        i[1]=i[1].replace(' ','')
                        setip="whmapi1 setsiteip ip=%s domain= %s" % (i[0], i[1])
                        print(setip)
                        subprocess.call(setip, shell=True)

if __name__ == "__main__":
    main()
