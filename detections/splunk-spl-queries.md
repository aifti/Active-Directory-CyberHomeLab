# Splunk Detection Queries

This file contains the SPL I used to validate and make sure that our Windows event logs were actually being forwarded to Splunk and to start mapping detections to MITRE ATT&CK.

# 1. (In this case we are going for RDP monitoring) RDP / Remote Interactive Logons

**THIS IS THE SPL QUERY WE USED TO OBTAIN OUR INFORMATION REGARDING ANY LOGS REGARDING LOGGING IN VIA RDP**

# Unauthorized Successful RDP Logins - Unknown IPs

**index="ablocal-ad" EventCode=4624 (Logon_Type=7 OR Logon_Type=10)
| where Source_Network_Address!="-"
      AND Source_Network_Address!="127.0.0.1"
      AND Source_Network_Address!="::1"
      AND Source_Network_Address!="192.168.1.167"
| stats count by time, ComputerName, Source_Network_Address, user, Logon_Type | sort - time**
(time variable should have an underscore before it)

**The purpose of this is to show who is using RDP and from where into our windows machines and to have a centralized way to monitor this using SPL queries via Splunk**

