## Oracle Grid infrastructure Prerequisites
Perform the following steps whilst logged into the "ol7-122-rac1" virtual machine as the root user.

#### Set the password for the "oracle" user.
passwd oracle

### Adjust /etc/hosts on both nodes
Apart from the localhost address, the "/etc/hosts" file can be left blank, but I prefer to put addresses in for reference.


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


 
