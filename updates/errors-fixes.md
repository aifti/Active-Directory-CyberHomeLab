
# Splunk Forwarding Setup — Troubleshooting & Progress Log

**Date Range:** November 3–4, 2025
**Author:** Abdullah Iftikhar
**Project:** SOC Home Lab (Splunk + Windows Forwarder Integration)

---

# Overview

This document tracks all errors, misconfigurations, and fixes encountered while setting up a Windows Server → Splunk Enterprise (Ubuntu) log forwarding pipeline using the **Splunk Universal Forwarder**. The goal was to get Windows event logs ingested into Splunk for SOC-style analysis and MITRE ATT&CK mapping.

---

# Environment

- **Splunk Enterprise (indexer):** Ubuntu VM — **Your Splunk SIEM IP Address**
- **Splunk Universal Forwarder:** Windows Server — **Your test machine server (client) IP Address**
- **Splunk Web UI:** port `8000/tcp` **Our HTTP Port for Splunk Web Interface**
- **Data receiving (forwarding):** port `9997/tcp` **This is the port which Splunk tends to receive log forwarding from**
- **Auth:** local Splunk user **(`Splunk admin name::Splunk password`)**
- **Firewalling:**
  - Ubuntu: UFW (port-based rules)
  - Windows: Windows Defender Firewall (custom ICMP + RDP rules)
- **Network:** VMs on bridged adapter, host-only access tightened

---

# Problem 1. Splunk Web Interface Not Loading (port 8000)

**Symptoms:**
- Going to `http://Ubuntu VM IP:8000` didn’t load Splunk Web.
- `splunk status` showed `splunkd ... was not running`.

**Root Cause:**
Splunk daemon (`splunkd`) wasn’t running — there was a stale PID from a previous run.

**Fix:**
sudo /opt/splunk/bin/splunk status
sudo /opt/splunk/bin/splunk start
sudo /opt/splunk/bin/splunk enable boot-start

Run these commads within the Splunk VM (Ubuntu)

# As an extra, you can allow port 8000 to run via the Linux UFW
sudo ufw allow 8000/tcp
sudo ufw reload
**As a result, the Splunk Web interface becomes accessible over port 8000 as long as your Splunk Server (Ubuntu VM) is up and running**


**THIS NEXT PROBLEM WAS ARGUABLY THE BIGGEST ONE OF THEM ALL, PLEASE READ THIS CAREFULLY AS YOU MAY RUN INTO THIS ISSUE**
# Problem 2. Forwarder Error: "No users exist. Please setup a user"
The command which caused this error (ESSENTIAL COMMAND): **.\splunk add forward-server 'Splunk Ubuntu IP':9997 -auth admin:changeme

**Root Causes**
    - Our Windows Splunk Universal Forwarder was installed earlier with a randomly generated password, however, when we were trying to run the above command to check if our logs were being forwarded, it required for the password to which we didn't have access to since we didn't know where it was due to the password being randomly generated, so to avoid this, we MUST create a password
    - The Splunk forwarder, specifically the **passwd** file (where the password is supposedly stored) was either:
        - in the wrong place (filepath/directory)
        - saved as passwd.txt (cannot be a text file)

**TO FIX THIS ISSUE**
Go to: C:\Program Files\SplunkUniversalForwarder\etc\

Make sure there is only a file called: passwd and not passwd.txt.

Put the correct line in that file (single line): **YOUR HASHED PASSWORD IN ONE LINE HERE**

Save as ASCII.
Restart the service:

net stop splunkforwarder
net start splunkforwarder
(or you can manually restart the splunkforwarder via services.msc in windows search bar, make sure to run it as administrator)

**Result: Forwarder could now authenticate with a real Splunk user**


# Problem 3. Splunk Forwarder shows "Configured but inactive forwards"
We must check if our splunk forwarding is effective, so we must run this command: **.\splunk list forward-server**

However, we run into this:
Active forwards:
  None
Configured but inactive forwards:
  **Your Ubuntu Splunk VM IP Address:9997**
**Root Cause --> The indexer (Ubuntu Splunk) was not listening on port 9997 yet**

Now in order to fix this: (type these commands in the Ubuntu VM)
sudo /opt/splunk/bin/splunk enable listen 9997 -auth 'Splunk Interface username':'Splunk Interface Password'
sudo ufw allow 9997/tcp
sudo ufw reload

**The result after restarting the forwarder (can be via services.msc or using net stop/start method)**
Active forwards:
    **Your Ubuntu VM IP address:9997**
Now your forwarder has officially become active


# Now to verify that our logs are being forwarded to Splunk

After running all of these steps, make sure to be logged into your Splunk Server via your Ubuntu VM

1: Once inside your Splunk Web Interface portal, head over to Apps, and click on **Search and Reporting**
2: For your new search, type in **index="Splunk Interface username"**
3: From there, you should be able to see all your event logs being forwarded

Hopefully after doing all these steps, your Splunk Universal Forwarder is forwarding all the appropriate logs ahead to the Splunk SIEM

