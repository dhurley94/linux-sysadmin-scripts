#!/usr/bin/env python
import subprocess
import os
from optparse import OptionParser

def main():
        usage = "usage: python %prog [options] arg"
        parser = OptionParser(usage)
        parser.add_option("-s", "--source", dest="sourceip", type=str,
                                        help="set the source ip address.")
        parser.add_option("-p", "--port", dest="sourceport", default="22",
                                        help="set port, defaults to 22 if not set")
        (options, args) = parser.parse_args()
        if (os.path.isfile("/etc/domainips-src") == False):
            if (options.sourceip is None):
                print("You must provide an IP address.")
                quit()
            else:
                try:
                    grabips = "rsync -ave 'ssh -p %s' %s:/etc/domainips /etc/domainips-src" % (options.sourceport, options.sourceip)
                    subprocess.call(grabips, shell=True)
                except Exception:
                    print ("\nrsync failed\nplease retry and manually move the /etc/domainips file to /etc/domainips-src on destination system\n")
                    quit()
        if (os.path.isfile("/etc/domainips-src")):
            f=open('/var/cpanel/mainip', 'r')
            mainip=f.read()
            try:
                input_file=open('/etc/trueuserdomains','r')
                for i in input_file:  # set all cPanel accounts to default main ip
                    i = i.split()
                    print("\n%s -> %s\n" % (i[1], mainip))
                    setip = "whmapi1 setsiteip ip=%s user=%s" % (mainip, i[1])
                    subprocess.call(setip, shell=True)
            finally:
                    input_file.close()
            try:
                input_file=open('/etc/domainips-src','r')
                next(input_file)
                for i in input_file:  # set all dedicated ip cPanel accounts to proper IP
                    i = i.split()
                    i[0] = i[0].replace(':', '')
                    i[1] = i[1].replace(' ', '')
                    print("\n%s -> %s\n" % (i[1], i[0]))
                    setip = "whmapi1 setsiteip ip=%s domain=%s" % (i[0], i[1])
                    subprocess.call(setip, shell=True)
            finally:
                    input_file.close()
            print("\n2ez42sbz\n")
            quit()
if __name__ == "__main__":
    main()
