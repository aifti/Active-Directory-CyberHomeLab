

# Overview

This phase documents how the Splunk SIEM and Shuffle SOAR platforms were integrated to automate detection and response to **unauthorized RDP logins** within the Active Directory Cybersecurity Homelab.  

The goal is to simulate a real-world **SOC workflow**, where Splunk detects a suspicious login (Event ID 4624) and automatically triggers a Shuffle playbook for analyst review and response.


# This is a recap of everything, starting with Lab Environment Recap

| Role | Purpose |
|------|----------|
| **DC01 (Windows Server)** | Domain Controller collecting Security event logs |
| **WIN-TEST** | Client VM generating authentication activity (logons, RDP, etc.) |
| **SPLUNK-UBUNTU** | Ubuntu 22.04 LTS hosting Splunk Enterprise SIEM |
| **SOAR (Shuffle)** | Orchestrates automated incident response actions |
| **Host Machine** | Runs all VMs inside VirtualBox with bridged networking |

# Networking Summary

- **Bridged Adapter Mode:** ensures each VM has a LAN IP (e.g. 192.168.1.x).  
- **Allowed Ports:** 22 (SSH), 8000 (Splunk Web), 9997 (Splunk Forwarding), 443 (Shuffle/Slack).  
- **Firewall Rules:**  
  - UFW on Splunk: allows inbound 22, 8000, 9997.  
  - Windows Firewall: allows ICMP + RDP from host only.


# Phase 1 –-> Splunk Enterprise Configuration

# 1. Enable Indexing & Forwarding

**Indexer (Ubuntu):**

sudo /opt/splunk/bin/splunk enable listen 9997 -auth **<your splunk user login>:your splunk password login>**
sudo ufw allow 9997/tcp
sudo systemctl restart splunk


# 2. Create Security Log Input

**This is the Path!! --> C:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf**

**Add this to the bottom of the .conf file**

[WinEventLog://Security]
index = <your index name>
disabled = 0


Restart the forwarder:

net stop splunkforwarder
net start splunkforwarder

# 3. Verify Data Ingestion

Go to Splunk Web → Search & Reporting → Run:

index="your index name" EventCode=4624


If you see Windows event data, ingestion is successful.



# Phase 2 -->  Detection Logic (SPL Queries)

**The objective is to detect unauthorized successful RDP Logins from any unrecognized/external IP's

index="ablocal-ad" EventCode=4624 (Logon_Type=7 OR Logon_Type=10)
| where Source_Network_Address!="-"
      AND Source_Network_Address!="127.0.0.1"
      AND Source_Network_Address!="::1"
      AND Source_Network_Address!="192.168.1.167"
| stats count by _time, ComputerName, Source_Network_Address, user, Logon_Type
| sort -_time

**Explanation:**
1. This query will filter out any loopback address (127.0.0.1 in our case), and any local testing machines IPs within the LAN

2. Flags any RDP attempts (Logon Type 10) and unlocks (Logon Type 7)

3. Displays only external or unknown IPs attempting successful logons


# Phase 3 --> Splunk Alert Creation: 

Create a real-time alert

**To create one, go to settings --> searches, reports, and alerts --> new alert**

# Example template of alert
    Alert Title:             Unauthorized Successful RDP Logins - Unknown IP
    Search:                  (SPL Query we made)
    Trigger Condition:       Number of Results > 0
    Trigger Action:          Webhook
    Severity:                High
    Cron Schedule:           Real-time per result (mine was * * * * * )
    Alert Owner:             (name of your splunk account user)


# Phase 4 --> Shuffle SOAR Workflow Integration:

Workflow Summary
Step	Action	Description
1. Webhook Trigger	Receives alert JSON from Splunk	Entry point for the playbook
2. Parse Fields	Extracts source_ip, user, and host	Simplifies payload
3. Conditional Logic	Check if IP is trusted	Skip trusted IPs (e.g., 192.168.1.167)
4. Slack Notification	Post message to analyst	“Suspicious RDP login detected – disable account?”
5. Analyst Input	User clicks YES/NO	Collected via Shuffle Web Form
6. Conditional Branch	If YES → AD action; If NO → Log decision	Simulates analyst triage
7. Active Directory Action	Disable user via PowerShell	Runs on domain controller using AD connector
8. Report Completion	Notify SOC via Slack/email	Confirms closure

    Example Slack Message


        Unauthorized RDP Login Detected!
        User: Administrator
        Host: WIN-TEST01.PersonalAD.local
        Source IP: 192.168.1.89
        Would you like to disable this account?

**Example Condition Node below**

IF:
user_action.answer == true
→ Run Active Directory “Disable Account” Node

ELSE:
→ Send “No Action Taken” message to Slack.
    


# Phase 5 --> Testing This Workflow

Attempt RDP login from another Windows device (192.168.1.89).

Confirm Splunk detects the event (EventCode 4624, LogonType=10).

Observe Splunk alert trigger and webhook firing to Shuffle.

Shuffle sends Slack message → click “YES”.

Check ADUC or PowerShell

If we go to our AD DC server, we can open up "Active Directory Users and Computers", go to the Users section and from there we should see the specified user's account disabled, if so, then it was a success.


# Phase 6 – Verification & Troubleshooting
**Issue	                Root    Cause	    Fix**

Splunk Web not loading	splunkd inactive	sudo /opt/splunk/bin/splunk restart

Forwarder says “No users exist”	passwd file missing	Recreate passwd under etc/

RDP events missing	Not collecting Security logs	Enable [WinEventLog://Security]

Shuffle not showing IP	Loopback event (127.0.0.1)	Added SPL filter for real IPs

Webhook payload empty	Wrong token or formatting	Re-test webhook in Splunk Alert UI



# Summary of Achievements So Far

1. Deployed SIEM (Splunk) and integrated SOAR (Shuffle).

2. Ingested Windows Security Logs (EventCode=4624) from multiple servers.

3. Correlated suspicious RDP logons and automated alerting.

4. Built full detection-to-response pipeline with human-in-the-loop Slack approval.

5. Documented all errors, fixes, and testing phases in updates/errors-fixes.md


