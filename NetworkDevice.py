# Class for ifcfg-eth* creation
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
