### Step 1 — Installing NTP
The NTP package is not installed by default, so you'll use the package manager to install it. First, update your packages:
```
sudo yum update
```

Then install NTP:
```
sudo yum install ntp
```
Once the installation completes, start the service and configure it so it starts automatically each time the server boots:
```
sudo systemctl start ntpd
sudo systemctl enable ntpd
```

If you've configured the firewall as specified in the prerequisites, you must allow UDP traffic for the NTP service in order to communicate with the NTP pool:
```
sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --reload
```
