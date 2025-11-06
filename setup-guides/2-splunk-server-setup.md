**Splunk Server Setup (Ubuntu 22.04.5)**

This document describes how I installed Splunk Enterprise on Ubuntu and prepared it to receive logs from my Windows Domain Controller and test machine.

# 1. Install dependencies

sudo apt update
sudo apt install -y wget curl net-tools

# 2. Install Splunk Enterprise

Make sure to download the .deb extension from Splunk and install it:

cd /tmp
sudo dpkg -i splunk-*.deb

Once you notice the dpkg completing the download, you can now officially start Splunk


# 3. Start Splunk and accept the license

sudo /opt/splunk/bin/splunk start --accept-license

**From here, you should be able to create your admin user account here, input your username and password**


# 4. Enable Splunk on the Web Interface

Normally Splunk Web will run on port 8000 by default, so let's allow it via the UFW on our Ubuntu

sudo ufw allow 8000/tcp
sudo ufw reload

**Now, go to your browser and type in: http://<your ubuntu(Splunk SIEM)-ip>:8000**


# 5. Enable receiving on 9997

This is where Windows will forward and set out the data to our Splunk SIEM

sudo /opt/splunk/bin/splunk enable listen 9997 -auth username:password
sudo ufw allow 9997/tcp

# 6. Startup on boot

sudo /opt/splunk/bin/splunk enable boot-start


# 7. Verify

sudo /opt/splunk/bin/splunk status
sudo netstat -tulnp | grep -E "8000|9997"

**From this, we should receive confirmation that our Splunk is listening on 0.0.0.0:8000 alongside 0.0.0.0:9997, now the rest is up to the Windows machines where the Splunk Universal Forwarder will point and send logs over to the Ubuntu SIEM Server**

