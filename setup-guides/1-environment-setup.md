# 1. Environment Setup

This guide explains the base environment I used to build the on-prem Active Directory + Splunk + SOAR homelab.

# Host Machine
- Windows 10 or 11
- VirtualBox (make sure it's set to bridged adapter)
- Promiscuous mode: **Allow VMs** (so Windows servers can talk to Ubuntu/Splunk), for Splunk you can set it to **Allow All**
- All VMs are on the same 192.168.1.0/24 LAN as the host

# Virtual Machines
| VM | Role | OS | Notes |
|----|------|----|-------|
| **DC01** | Active Directory Domain Controller | Windows Server | Generates security events, RDP restricted to host |
| **WIN10-TEST** | Domain workstation / test machine | Windows (client) | Used to simulate logons to the domain |
| **SPLUNK-UBUNTU** | SIEM / log receiver | Ubuntu 22.04.5 LTS | Runs Splunk Enterprise on port 8000, receives on 9997 |
| **SOAR**| Shuffle / future automation | Linux | Will be used to trigger actions on alerts |

# Networking (very important)
1. **All VMs use Bridged Adapter** so they get real 192.168.1.x addresses.
2. Host NIC must be on the same LAN as the VMs.
3. On the host I set the network profile to **Private** so Windows firewall would allow ICMP and file/printer sharing.
4. On Windows servers I enabled ICMP inbound so VMs can ping each other.

See also: [networkconfiguration.md](./networkconfiguration.md) for the full troubleshooting notes I hit while getting VM ↔ VM connectivity working.

# Order of Build
1. Create all VMs
2. Make sure they can all **ping each other**
3. Harden Windows firewalls (RDP only from host, allow ICMP from VMs)
4. Install Splunk on Ubuntu
5. Install Splunk Universal Forwarder on Windows boxes

**This should be a good overview of what this lab looks like from a top-down view, and the specifics will be in the following files for you to read incase you need specific help regarding certain issues**
