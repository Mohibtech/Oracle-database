## Oracle Installation Prerequisites
Perform either the Automatic Setup or the Manual Setup to complete the basic prerequisites. The Additional Setup is required for all installations.
Automatic Setup
If you plan to use the "oracle-database-server-12cR2-preinstall" package to perform all your prerequisite setup, issue the following command.
```
yum install oracle-database-server-12cR2-preinstall -y
```

Earlier versions of Oracle Linux required manual setup of the Yum repository by following the instructions at http://public-yum.oracle.com.
It is probably worth doing a full update as well, but this is not strictly speaking necessary.
```
yum update -y
```
