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
        target.write("NETWORK=" + ifcfg.network + "\n")
        target.write("NETMASK=" + ifcfg.subnet + "\n")
        target.write("IPADDR=" + ifcfg.mainip + "\n")
        target.write("HWADDR=" + ifcfg.hwaddr + "\n")
        target.close()

    # creates route-eth*

# creates route-eth*
def createroute(filename, ifcfg):
        # ie: route-eth0
        target = open(filename, 'w+')
        target.write(ifcfg.network + " via " + ifcfg.gateway + "\n") # todo needs device and subnet
        target.close()

# create /etc/sysconfig/networkyyeee
def createnetwork(ifcfg):
    target = open("network", 'w+')
    target.write("NETWORKING=yes")
    target.write("GATEWAY=" + ifcfg.gateway + "\n")
    target.close()

# create array of ip range for config creation
def validHosts(mainip, hosts):
    mainip = mainip.split('.')
    validLast = []
    for i in range(int(hosts)):
        validLast.append(int(mainip[3]) + i)
    valid = []
    for i in range(hosts):
        valid.append(str(mainip[0]) + "." + str(mainip[1])  + "." + str(mainip[2]) + "." + str(validLast[i]))
    return valid

net = NetworkDevice("eth0", "192.168.1.100", "192.168.1.0", "192.168.1.1", "255.255.255.248")

print validHosts(net.mainip, net.hosts)
createfile("testing-eth", net)
createroute("testing-route", net)
createnetwork(net)
