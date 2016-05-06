# general concept
# does not work yet

#!/usr/bin/env python
import sys
from uuid import getnode as get_mac

bit = get_mac()
hwaddr = '%012x' % bit

print hwaddr

# split hwaddr

gate = "10.10.10.31"
start = "10.10.10.32"
end = "10.10.10.36"

# loop add temp ip
# needs to echo into ifcfg-eth0 for persistance after reboot
for i in range(start - finish):
        ip route add i/29 dev eth0
route add default gw gate eth0

# if primary ip
echo start via gate dev eth0 >> /etc/sysconfig/network-scripts/route-eth0
