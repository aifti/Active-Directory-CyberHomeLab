**Network Configuration & Connectivity**

For our lab, we are using a bridged LAN design where each VM receives its own IP from the host’s local subnet (assigned).
This simulates an enterprise environment where systems communicate over the same network segment.

**Network Overview**

System              Role                Adapter Type                Promiscous Mode             IP Address
Host Machine        Physical Node       Bridged Adapter             N/A                         Host Machine IP

Window Server ADDC  Domain Controller   Bridged Adapter             Allow VMs                   ADDC IP

Windows Machine     Domain Workstation  Bridged Adapter             Allow VMs                   Machine IP

Splunk (Ubuntu)     SIEM/Log Collector  Bridged                     Allow All                   Splunk Server IP

**SOME TROUBLESHOOTING WE DID IN ORDER FOR OUR INTERCONNECTIVITY TO WORK WITHIN OUR LAN**
**PLEASE READ THIS CAREFULLY AS I GO INTO GREATER DETAIL ON HOW TO REMEDIATE THESE ISSUES IN CASE YOU FACE THE SAME**

1. Our Host Machine was originally set to Public, we set it to Private which allows discovery
2. Created custom ICMPv4 firewall rule (for some reason none even existed by default)
3. Enabled Windows ICMP rules on both Windows Servers to restore the VM to VM connectivity
4. Finally verified that the bridged adapter was set to our NIC (shown above), promiscuous mode = Allow VMs

**Firewall Configuration**

Host Machine 
We made a custom ICMP rule which was created to allow ping diagnostics and connectivity from VMs via Powershell

New-NetFirewallRule -Name "Allow-ICMPv4-In"
  -DisplayName "Allow ICMPv4 Echo Requests (Ping)"
  -Protocol ICMPv4 -Direction Inbound -Action Allow
  -Profile Domain,Private,Public

**Windows Server/Client VMs**
In order for the VMs to ping within each other and have connectivity, we have to allow a custom ICMP rule within these servers via Powershell

Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"
Set-NetFirewallProfile -Profile Domain,Private,Public -AllowInboundRules True


**Splunk (Ubuntu)**
sudo ufw allow from 192.168.1.167 to any port 22 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 8000 proto tcp   #Splunk Web
sudo ufw allow from 192.168.1.0/24 to any port 9997 proto tcp   #Forwarder traffic
sudo ufw enable

Now, we are able to have interconnectivity within our VMs to each other, and we as the host can reach out to each VM, with the VM also being able to do the same

**Network Summary**

1. Bridged Adapter mode ensures real LAN behavior.
2. Host to VM, and VM to VM communication verified with ICMP.
3. Firewalls configured for ICMP + Splunk ports only.
4. Access limited to internal 192.168.1.0/24 subnet.
5. No external exposure (hopefully)