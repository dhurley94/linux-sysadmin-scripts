#!/usr/bin/env python
from uuid import getnode as get_mac

class NetworkDevice:
    def __init__(self, dev, mainip, subnet):
        self.dev = dev
        self.mainip = mainip
        self.subnet = subnet
        self.octets = self.mainip.split('.')

    # local uuid > hex > mac conversion
    def gethwaddr(self):
        uuid = get_mac()
        uuid = '%012x' % uuid
        mac = ""
        for i in range(5):
            if i != 4:
                mac += uuid[i] + uuid[i + 1] + ":"
            else:
                mac += uuid[i] + uuid[i + 1]
        return mac.upper()

    # return network id
    def getnetwork(self):
        return int(self.octets[3]) - 2

    # return default gateway
    def getgateway(self):
        return int(self.octets[3]) - 1

    def gethosts(self):
        subList = self.subnet.split('.')
        return 256 - int(subList[3]) - 3
