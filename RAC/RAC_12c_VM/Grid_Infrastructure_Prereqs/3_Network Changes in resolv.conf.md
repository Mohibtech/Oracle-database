## Network Changes including resolv.conf 
Make sure `"/etc/resolv.conf"` file includes a nameserver entry that points to the correct nameserver. Also, if the "domain" and "search" entries are both present, comment out one of them. For this installation my `"/etc/resolv.conf"` looked like this.

> #domain localdomain
search localdomain
nameserver 192.168.56.1


The changes to the `"resolv.conf"` will be overwritten by the network manager, due to the presence of the NAT interface. 
For this reason, this interface should now be disabled on startup. You can enable it manually if you need to access the internet from VMs. 

