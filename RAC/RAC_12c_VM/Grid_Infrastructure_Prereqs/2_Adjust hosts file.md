### Adjust /etc/hosts on both nodes
Apart from the localhost address, the "/etc/hosts" file can be left blank, but I prefer to put addresses in for reference.

> 127.0.0.1             localhost.localdomain   localhost  
#################### Public ##############################  
192.168.56.101   ol7-122-rac1.localdomain        ol7-122-rac1  
192.168.56.102   ol7-122-rac2.localdomain        ol7-122-rac2  
##################### Private ##########################  
192.168.1.101   ol7-122-rac1-priv.localdomain   ol7-122-rac1-priv  
192.168.1.102   ol7-122-rac2-priv.localdomain   ol7-122-rac2-priv  
##################### Virtual ##########################   
192.168.56.103   ol7-122-rac1-vip.localdomain    ol7-122-rac1-vip  
192.168.56.104   ol7-122-rac2-vip.localdomain    ol7-122-rac2-vip  
##################### SCAN ######################  
#192.168.56.105   ol7-122-scan.localdomain ol7-122-scan  
#192.168.56.106   ol7-122-scan.localdomain ol7-122-scan  
#192.168.56.107   ol7-122-scan.localdomain ol7-122-scan  

SCAN address is commented out of the hosts file because it must be resolved using a DNS, so it can round-robin between 3 addresses on the same subnet as the public IPs. 
DNS can be configured on the host machine using BIND or Dnsmasq, which is much simpler. 
If you are using Dnsmasq, put RAC-specific entries in hosts machines "/etc/hosts" file, with SCAN entries uncommented, restart Dnsmasq.
