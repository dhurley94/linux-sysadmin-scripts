#!/usr/bin/env python
from uuid import getnode as get_mac

class NetworkDevice:
    def __init__(self, dev, mainip, network, gateway, subnet):
        self.dev = dev
        self.mainip = mainip
        self.network = network
        self.subnet = subnet
        self.gateway = gateway
        # uuid > hex > mac conversion
        uuid = get_mac()
        uuid = '%012x' % uuid
        mac = ""
        for i in range(5):
            if i != 4:
                mac += uuid[i] + uuid[i + 1] + ":"
            else:
                mac += uuid[i] + uuid[i + 1]
        self.hwaddr = mac.upper()

        # find available hosts in subnet

        self.sublist = subnet.split('.')
        self.hosts = 256 - int(self.sublist[3]) - 3

    # creates ifcfg-eth*
    def createfile(self, filename):
            # ie: ifcfg-eth0
            target = open(filename, 'w+')
            target.truncate()
            target.write("ONBOOT=yes\nBOOTPROTO=static\n")
            target.write("DEVICE=" + self.dev + "\n")
            target.write("NETWORK=" + ifcfg.network + "\n")
            target.write("NETMASK=" + ifcfg.subnet + "\n")
            target.write("IPADDR=" + ifcfg.mainip + "\n")
            target.write("HWADDR=" + ifcfg.hwaddr + "\n")
            target.close()

    # creates route-eth*
    def createroute(self, filename):
            # ie: route-eth0
            target = open(filename, 'w+')
            target.write(self.network + " via " + self.gateway + "\n") # todo needs device and subnet
            target.close()

    # create /etc/sysconfig/networkyyeee
    def createnetwork(self):
        target = open("network", 'w+')
        target.write("NETWORKING=yes")
        target.write("GATEWAY=" + self.gateway + "\n")
        target.close()

    # create array of ip range for config creation
    def validHosts(self):
        mainip = self.mainip.split('.')
        validLast = []
        for i in range(int(self.hosts)):
            validLast.append(int(mainip[3]) + i)
        valid = []
        for i in range(self.hosts):
            valid.append(str(mainip[0]) + "." + str(mainip[1])  + "." + str(mainip[2]) + "." + str(validLast[i]))
        return valid
