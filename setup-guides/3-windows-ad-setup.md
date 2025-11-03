**Windows Server Hardening (Domain Controller + Test Machine)**

I will be discussing the many features I have taken to harden both of these servers, this serves as a good baseline to take from when hardening your Windows Servers

1) **Disable Network Discovery & File Sharing**
    Open the control panel, go to Network & Sharing Center, then Advanced Settings
    From there, turn off Network Discovery and File & Printer Sharing for all the profiles


2) **Restrict Remote Assistance**
    From the windows search bar, type in "sysdm.cpl", head over to the remote tab, and select Remote Assistance enabling under RDP
    From there, we will head over to allow only specific IP's to access us via RDP in the next step

3) **Restrict RDP Access to Host Only**
    Open Windows Defender Firewall --> Advanced Settings
    Click on Inbound Rules, and look for Remote Desktop (TCP-In) for users. Right click on it, select properties, and then scope
    Under Remote IP address, choose "These IP addresses" and add whatever your host IP address is
    Now, after applying and closing the settings, your host should be the only one that can access this server

4) **Additional Firewall Rule for Host Admin Access**
    New-NetFirewallRule -DisplayName "Allow Host Admin Access"
        -Direction Inbound -Action Allow -RemoteAddress **host IP**

5) **Validate RDP Restriction**
    Test-NetConnection **server IP** -Port 3389

        At this point, the host should successfully be able to reach connectivity, whereas any other LAN devices fail 

6) **Enable ICMP Between VMs**
        Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"

7) **Confirm All Profiles Allow Inbound**
        Set-NetFirewallProfile -Profile Domain,Private,Public -AllowInboundRules True

        By running these commands from steps 6 + 7, you should be able to commute between your servers and hosts successfully


**Final Outcome**

Only the host can RDP into the Windows Server VMs
All the internal ICMP and Splunk log forwarding should be working
Any external LAN devices should not be able to connect to us
This environment should be fully hardened for our on-premise SOC lab use