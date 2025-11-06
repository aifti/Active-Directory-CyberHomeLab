# Splunk Detection Queries

This file contains the SPL I used to validate and make sure that our Windows event logs were actually being forwarded to Splunk and to start mapping detections to MITRE ATT&CK.

# 1. (In this case we are going for RDP monitoring) RDP / Remote Interactive Logons

**THIS IS THE SPL QUERY WE USED TO OBTAIN OUR INFORMATION REGARDING ANY LOGS REGARDING LOGGING IN VIA RDP**

index="ablocal-ad" EventCode=4624 (Logon_Type=10 OR Logon_Type=7) Source_Network_Address=*
| stats count by Account_Name, Source_Network_Address, Logon_Type
| rename Account_Name AS user, Source_Network_Address AS src_ip
| sort - count

**The purpose of this is to show who is using RDP and from where into our windows machines and to have a centralized way to monitor this using SPL queries via Splunk**

