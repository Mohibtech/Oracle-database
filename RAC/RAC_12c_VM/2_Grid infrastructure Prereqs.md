## Oracle Grid infrastructure Prerequisites
Perform the following steps whilst logged into the "ol7-122-rac1" virtual machine as the root user.

#### Set the password for the "oracle" user.
passwd oracle

### Adjust /etc/hosts on both nodes
Apart from the localhost address, the "/etc/hosts" file can be left blank, but I prefer to put addresses in for reference.

```
127.0.0.1             localhost.localdomain   localhost  
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
```

SCAN address is commented out of the hosts file because it must be resolved using a DNS, so it can round-robin between 3 addresses on the same subnet as the public IPs. 
DNS can be configured on the host machine using BIND or Dnsmasq, which is much simpler. 
If you are using Dnsmasq, put RAC-specific entries in hosts machines "/etc/hosts" file, with SCAN entries uncommented, restart Dnsmasq.

 
## Network Changes including resolv.conf 
Make sure `"/etc/resolv.conf"` file includes a nameserver entry that points to the correct nameserver. Also, if the "domain" and "search" entries are both present, comment out one of them. For this installation my `"/etc/resolv.conf"` looked like this.

```
#domain localdomain
search localdomain
nameserver 192.168.56.1
```

The changes to the `"resolv.conf"` will be overwritten by the network manager, due to the presence of the NAT interface. For this reason, this interface should now be disabled on startup. You can enable it manually if you need to access the internet from VMs. 

### Edit enp0s3
Edit `"/etc/sysconfig/network-scripts/ifcfg-enp0s3"` (eth0) file, making the following change. This will take effect after the next restart.
```
ONBOOT=no
```

There is no need to do the restart now. You can just run the following command. Remember to amend the adapter name if yours are named differently.

> ifdown enp0s3
> #ifdown eth0


At this point, the networking for the first node should look something like the following. Notice that enp0s3 (eth0) has no associated IP address because it is disabled.
```
# ifconfig
enp0s3: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 08:00:27:f6:88:78  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
enp0s8: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.56.101  netmask 255.255.255.0  broadcast 192.168.56.255
        inet6 fe80::cf8d:317d:534:17d9  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:82:06:32  txqueuelen 1000  (Ethernet)
        RX packets 574  bytes 54444 (53.1 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 547  bytes 71219 (69.5 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
enp0s9: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.101  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::9a9a:f249:61d1:5447  prefixlen 64  scopeid 0x20<link>
        ether 08:00:27:2e:2c:cf  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 29  bytes 4250 (4.1 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 0  (Local Loopback)
        RX packets 68  bytes 5780 (5.6 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 68  bytes 5780 (5.6 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
virbr0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 192.168.122.1  netmask 255.255.255.0  broadcast 192.168.122.255
        ether 52:54:00:4a:12:2f  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

### SCAN Address resolve to all 3 IP Addresses
With this in place and the DNS configured the SCAN address is being resolved to all three IP addresses.
```
# nslookup ol7-122-scan
Server:		192.168.56.1
Address:	192.168.56.1#53
Name:	ol7-122-scan.localdomain
Address: 192.168.56.105
Name:	ol7-122-scan.localdomain
Address: 192.168.56.106
Name:	ol7-122-scan.localdomain
Address: 192.168.56.107
```

## Change SELinux to permissive
Change setting of SELinux to permissive by editing the "/etc/selinux/config" file, making sure SELINUX flag is set as follows.
```
SELINUX=permissive
```

## Disable Linux Firewall 
If you have Linux firewall enabled, you will need to disable or configure it. 
The following is an example of disabling the firewall.
```
# systemctl stop firewalld
# systemctl disable firewalld
```

