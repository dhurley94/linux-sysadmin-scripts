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

net = NetworkDevice("eth0", "192.168.1.100", "192.168.1.0", "192.168.1.1", "255.255.255.0")

createfile("testing-eth", net)
createroute("testing-route", net)
createnetwork(net)
