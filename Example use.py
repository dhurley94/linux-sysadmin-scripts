# todo
# incorporate user input for ranges of ip adddresses / autograb from src server (read from /etc/ips?)
# loop through and backup curcial information from both servers w/ .bak
# remove files on dst and grab all with rsync.
# generate old / new ifcfg for both servers.
# user validate information
# send and apply config files to both servers
# create menu system

#!/usr/bin/env python
from NetworkDevice import NetworkDevice

# creates ifcfg-eth*
def createfile(filename, ifcfg):
        # ie: ifcfg-eth0
        target = open(filename, 'w+')
        target.truncate()
        target.write("ONBOOT=yes\nBOOTPROTO=static\n")
        target.write("DEVICE=" + ifcfg.dev + "\n")
        target.write("NETWORK=" + ifcfg.getnetwork() + "\n")
        target.write("NETMASK=" + ifcfg.subnet + "\n")
        target.write("IPADDR=" + ifcfg.mainip + "\n")
        target.write("HWADDR=" + ifcfg.gethwaddr() + "\n")
        target.close()
    # creates route-eth*

# creates route-eth*
def createroute(filename, ifcfg):
        # ie: route-eth0
        target = open(filename, 'w+')
        target.write(ifcfg.getnetwork() + " via " + ifcfg.getgateway() + "\n") # todo needs device and subnet
        target.close()
# create /etc/sysconfig/networkyyeee
def createnetwork(ifcfg):
    target = open("network", 'w+')
    target.write("NETWORKING=yes")
    target.write("GATEWAY=" + ifcfg.getgateway()+ "\n")
    target.close()

# create array of ip range for config creation
def validHosts(mainip, hosts): # todo fix this
    mainip = mainip.split('.')
    validLast = []
    for i in range(int(hosts)):
        validLast.append(int(mainip[3]) + i)
    valid = []
    for i in range(hosts):
        valid.append(str(mainip[0]) + "." + str(mainip[1])  + "." + str(mainip[2]) + "." + str(validLast[i]))
    return valid

RANGES = []

num =  int(raw_input("Input how many ranges.\n"))

for i in range(num):
    print "Data for ip range #" + str(i) + "\n"
    dev = raw_input("Name of device? ie: eth0\n")
    mainip = raw_input("First valid ip address\n")
    subnet = raw_input("Valid Subnet? ie: 255.255.255.248\n\n")
    RANGES.append(NetworkDevice(dev, mainip, subnet))

for i in range(len(RANGES)):
    print "Ranges #" + str(i)
    print "Device ID: " + RANGES[i].dev
    print "Main IP: " + RANGES[i].mainip
    print "Subnet: " + RANGES[i].subnet
    print "Hardware Address: " + RANGES[i].gethwaddr()
    print "Network ID: " + str(RANGES[i].octets[0]) + "." + str(RANGES[i].octets[1]) + "." + str(RANGES[i].octets[2]) + "." + str(RANGES[i].getnetwork())
    print "Gateway: " + str(RANGES[i].octets[0]) + "." + str(RANGES[i].octets[1]) + "." + str(RANGES[i].octets[2]) + "." + str(RANGES[i].getgateway())
    #print "All valid hosts in subnet: " + str(validHosts(RANGES[i].mainip, RANGES[i].gethosts()))
