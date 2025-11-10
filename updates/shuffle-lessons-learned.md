Lessons Learned: Splunk–Shuffle–Active Directory Automation Attempt
**Date:** November 10, 2025  
**Category:** SOAR Integration • Troubleshooting Log • Reflection  

---

## 🔹 Project Overview
This phase of the **Active Directory Cyber Homelab** explored end-to-end automation using:
- **Splunk** for detection of suspicious RDP logins (Event ID 4624, Logon Type 7 or 10)
- **Shuffle (SOAR)** for workflow automation
- **Slack** for analyst notifications
- **Active Directory (AD)** for user account control

**Goal:**  
When Splunk detects a suspicious RDP login from an unknown or external IP, Shuffle sends a Slack/email alert requesting analyst approval. If approved, the workflow disables the AD account automatically.

---

## 🧩 Environment Summary

| Component | Purpose |
|------------|----------|
| **Windows Server 2022 (AD/DC)** | Domain controller for account management |
| **Windows 10 Workstation** | Generates test logins + events |
| **Ubuntu Server 22.04 (Splunk)** | Collects and indexes Windows Event Logs |
| **Shuffle (SOAR Cloud)** | Orchestrates the automation |
| **Slack** | Notification and analyst confirmation channel |

---

# Setup and Progress

# Splunk Detection
- Installed **Universal Forwarder** on both DC and client.  
- Manually configured `inputs.conf` for Security Event Logs.  
- Created custom SPL to identify external RDP logins:

  index="ablocal-ad" EventCode=4624 (Logon_Type=7 OR Logon_Type=10)
  | where Source_Network_Address!="192.168.1.167" AND Source_Network_Address!="-"
  | stats count by _time, ComputerName, Source_Network_Address, user, Logon_Typei


  **We verified that these results showed valid and legitimate external login sources**


# 2. Slack Integration

Initial OAuth error (“invalid_scope”) prevented app authorization.

Fixed by building a new custom Slack App:

Added redirect URI from Shuffle.

Applied required bot scopes: chat:write, channels:read, im:write, groups:read.

Confirmed functional message delivery to #alerts with timestamp conversions.

Used PowerShell to convert EPOCH time for validation:

**(Get-Date 01.01.1970).AddSeconds(<EPOCH>)**

# 3. Shuffle Workflow Design

**This is our Created workflow:**

Splunk Webhook → Slack Alert → User Action (Email) → Condition → Active Directory → Slack Confirmation

User Action prompt:

**Action Required!
Do you want to disable this user?**


Condition set to trigger only if analyst approval = true.

# 4. Active Directory Node

**Integrated AD-LDAPS connection using domain credentials. (We need LDAP since it works with AD to search and query users and other features)**

Tested with disable_user for samaccountname: HWill.

Verified LDAP connectivity within local network.

# HOWEVER, We Faced Major Roadblocks & Observations
1. Email Form Failure

    Clicking “Yes” in Shuffle email opened Runtime Argument form instead of proceeding.

    Cause: User Input node lacked explicit variable mapping (answer not defined).

    Workaround: Using frontend_continue link updated click_info.clicked = true, but behavior was inconsistent and unreliable.

2. Conditional Logic Skipped

    Workflow returned: Minimum of one branch’s conditions must be correct to continue.


    Original condition used $User_Action.answer == true; corrected to $User_Action.click_info.clicked == true. However, even after correction, workflow sometimes failed to resume, suggesting race conditions in Shuffle’s event-handling.

3. Connectivity & LDAPS Timeouts

    Shuffle (cloud) intermittently failed to reach on-prem AD. LDAPS port 636 showed partial connectivity—bind success without operation execution. I ran some Local tests (PowerShell/LDAP browser) confirmed DC was reachable internally.


4. Port Forwarding Attempt

    Attempted to port-forward LDAPS (636) and LDAP (389) on the home router to the AD server. Shuffle connected via public IP but failed to disable users.

    However, the drawback in this case is that external exposure posed security risk (domain controller accessible publicly). We ultimately disabled port forwarding due to the issue still persisting and security risks.

    Lesson: Port forwarding AD is not a safe or sustainable solution—use local runner, VPN, or reverse proxy instead.

5. Workflow Stalling

    Shuffle often paused indefinitely in WAITING state post-User Action.

    Logs confirmed click_info.clicked = true but no subflow resumption.

    This indicates potential limitations with Shuffle’s cloud form state handling in hybrid labs.

# Key Lessons Learned
**Takeaways**

Workflow Design	--> Always prototype the automation logic locally (e.g., Python + LDAP) before porting to SOAR.
Networking	--> Cloud SOARs struggle in NAT’d labs—self-host Shuffle or use VPN relay.
Security --> 	Never forward AD ports to the internet; use tunnel or reverse proxy.
Logic Mapping --> Shuffle User Input requires explicit JSON keys; missing mappings cause silent failures.
Dependence	--> External connectivity can break otherwise valid logic—design for hybrid environments.
Documentation --> Maintaining logs, screenshots, and SPL references streamlined debugging and root-cause tracking.

# Potential Future Fixes (If we were to approach this project/situation from a different angle)

1. Host Shuffle locally via Docker for direct LDAP communication.

2. Replace email form with Slack buttons or a Flask API endpoint for analyst approval.

3. Add LDAP connectivity check node before disabling user.

4. Implement fail-safe logging node to send status back to Splunk index.

5. Secure inbound testing with VPN instead of public port forwarding.

# Final Reflection

**Although the workflow never reached full automation, the process provided significant insight into many key details, including:

1. SIEM–SOAR Integration principles

2. LDAP authentication & LDAPS trust

3. Cloud-to-on-prem architecture constraints

4. Error handling in conditional automation

5. Safe network exposure practices

**This stage showed that effective security automation is less about writing conditions and more about ensuring systems can actually reach and trust each other.**

# Summary of Project

**Functional** -->	Splunk detection, Slack alerts, Shuffle email trigger
**Partial** -->	Form submission logic, conditional evaluation
**Incomplete** --> Automatic AD disable execution over cloud connection
**Outcome** --> Practical lessons in SOAR workflow design, network reachability, and secure automation practice
