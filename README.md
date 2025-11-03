# Active Directory Cybersecurity Homelab

Overview
This repository documents my current ongoing cybersecurity homelab where I am building a small **Active Directory + SIEM + SOAR** environment to detect and respond to **unauthorized logins**.

The Goal: simulate what an entry-level SOC analyst or blue teamer would do:
1. collect Windows/AD logs,
2. send them to Splunk on Ubuntu,
3. detect a suspicious login,
4. trigger an automated workflow (SOAR) to notify and/or disable the account. 

On **2025-10-28** I migrated this from cloud VMs to **on-prem VirtualBox VMs** so I could fully control SSH, firewall rules, and network modes. 

---

Lab Components

- **DC01 (Windows Server)** – Active Directory Domain Controller
- **WIN10-TEST** – test client to generate logon events
- **SPLUNK-UBUNTU** – Ubuntu 22.04.5 LTS running Splunk, SSH-hardened
- **SOAR (Shuffle)** – receives alert from Splunk and asks whether to disable domain account
- **Host PC** – runs VirtualBox and is the **only IP allowed to SSH** into the Splunk VM

High-level flow:

1. Windows test machine → successful login
2. Logs → DC → Splunk
3. Splunk → detects “unauthorized or unusual login”
4. Splunk → SOAR (Shuffle) → ask analyst
5. If confirmed → disable AD account on DC 

---

# PLEASE READ!!!!!!! ----> Networking Notes (Important)

I run these VMs in VirtualBox with:

- **Bridged Adapter** → so the Ubuntu/Splunk VM gets a real LAN IP (ex: `192.168.1.43`)
- **Promiscuous Mode: Allow All** → so my Windows host can actually reach the VM

**MAKE SURE THAT YOUR VM IS SET TO BRIDGED, NOT NAT OTHERWISE IT WILL BE NOT BE REACHABLE BY OTHER HOSTS**
- Then I restricted SSH on the Ubuntu VM to **only my host IP** using UFW.

This part was tricky because I originally had a rule like:

22/tcp DENY IN Anywhere
22/tcp ALLOW IN **host ip address**

In this above text, we can see that the first rule was a **DENY IN** which preceded first before the **ALLOW IN** rule. This unfortunately caused my SSH to time out everytime I would try to establish a connection. I fixed this by deleting this rule and readded the       **ALLOW** rule so that way it would be evaluated first.
 
---

# SSH Hardening

1. /etc/ssh/sshd_config:
PermitRootLogin no
PasswordAuthentication no
AllowUsers **your username**

2. UFW rules (host-only in this case)
sudo ufw allow from **host ip address** to any port 22 proto tcp
sudo ufw deny 22/tcp
sudo ufw status numbered

3. Key-based auth:
ssh-keygen -t ed25519 (algorithim) -C **name of key** key
ssh-copy-id **username@serverip**

4. Restart SSH:
sudo systemctl restart ssh


















