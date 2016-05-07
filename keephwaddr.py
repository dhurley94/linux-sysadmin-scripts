# does not work yet

#!/usr/bin/env python
from uuid import getnode as get_mac
import sys

# uuid > hex > mac
def getMAC():
    uuid = get_mac()
    uuid = '%012x' % uuid
    mac = ""
    for i in range(5):
        if (i != 4):
            mac += uuid[i] + uuid[i+1] + ":"
        else:
            mac += uuid[i] + uuid[i + 1]
    return mac.upper()

# find available hosts in subnet
def findHosts(subnet):
    subnet = subnet.split('.')
    return 256 - int(subnet[3]) - 3

def createFile(self, dev, ip, network, subnet, gateway, hwaddr):
    target = open('file')
    target.write("ONBOOT=yes\nBOOTPROTO=static\n")
    target.write("DEVICE=" + dev)
    target.close()

class config:
    def __init__(self, dev, ip, hosts, network, subnet, gateway, hwaddr):
        self.dev = dev
        self.ip = ip
        self.hosts = hosts
        self.network = network
        self.subnet = subnet
        self.gateway = gateway
        self.hwaddr = hwaddr

print getMAC()

# split hwaddr

gate = "184.154.148.193"
ip = "184.154.148.194"
sub = "255.255.255.248"

ipList = ip.split('.')


for i in range(findHosts(sub)):
    print int(ipList[3]) - 1
    print int(ipList[3]) + i
    print sub


# create ifcfg-eth*

# if primary ip
#echo start via gate dev eth0 >> /etc/sysconfig/network-scripts/route-eth0
