# Nessus Vulnerability Management Project  
# Windows Server 2022 | CVE Remediation | CIS Hardening | Authenticated Scan

---

## **1. Overview**
This project demonstrates a full vulnerability management workflow using **Nessus Essentials**, targeting a Windows Server 2022 system in an Active Directory homelab.  
Work includes:

- Running an **authenticated Nessus scan**
- Identifying 30+ findings, including **one High severity CVE (CVE-2013-3900)**
- Applying Microsoft’s official fix for WinVerifyTrust signature validation
- Implementing a **CIS Benchmark (CIS 2.3.7.3 – Require NLA for RDP)**
- Re-running Nessus to verify remediation
- Documenting before/after results

---

## **2. Environment Details**
- **Target OS:** Windows Server 2022 Standard (Domain Controller)  
- **Domain:** PersonalAD.local  
- **Client System:** Windows 10  
- **SIEM:** Splunk Enterprise  
- **SOAR:** Shuffle  
- **IP:** 192.168.1.237  
- **Scanner:** Nessus Essentials (local authenticated scan)

---

## **3. Scan Configuration**
- **Scan Type:** Basic Network Scan  
- **Credentials Used:** Domain user (Windows authenticated scan)  
- **Plugins:** Fully updated  
- **Scope:** Single Windows Server 2022 DC  
- **Reason for authenticated scan:** Enables registry checks, patch validation, service configuration review

---

## **4. Pre-Remediation Results**
Key findings from the initial baseline scan:

- **Total vulnerabilities:** 52  
- **High severity:** 1  
- **Medium severity:** SMB Signing Not Required, TLS issues  
- **Low/Informational:** RDP detected, service enumeration, DNS hostname detection  

Screenshots located in (hopefully):  
`/assets/nessus-before/`

---

## **5. High Severity Finding — CVE-2013-3900**
**Name:** WinVerifyTrust Signature Validation Mitigation Missing  
**Severity:** High (CVSS 8.8)

### **What the vulnerability means (simple):**  
Windows doesn't fully validate Authenticode signatures, meaning a hacker can modify a legitimately signed executable while keeping the digital signature valid.

This breaks the trust chain and enables supply-chain style malware attacks.

### **Detected because:**  
Nessus found that the registry values enabling certificate padding checks were missing.

Screenshots located in:  
`/assets/cve-2013-3900/`

---

## **6. Remediation Steps (Microsoft WinVerifyTrust Fix)**

### **PowerShell/Command Line Fix Applied**
```cmd
reg add "HKLM\Software\Microsoft\Cryptography\Wintrust\Config" /v EnableCertPaddingCheck /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config" /v EnableCertPaddingCheck /t REG_DWORD /d 1 /f
shutdown /r /t 0
```

### **Result:**  
- CVE-2013-3900 successfully patched  
- High severity risk removed  

Files placed in:  
`/scripts/enable-cert-padding.ps1`

---

## **7. CIS Benchmark Hardening**
**CIS Control Applied:**  
### **CIS 2.3.7.3 — Require Network Level Authentication (NLA)**

### **Steps:**
1. Run: `sysdm.cpl`  
2. Open **Remote** tab  
3. Enable:  
   **Allow connections only from computers running Remote Desktop with Network Level Authentication**

## **8. Post-Remediation Scan**
A follow-up Nessus scan was performed to validate remediation.

### **Results:**
- **High severity reduced: 1 → 0**  
-  Medium findings reduced  
-  System hardening confirmed  
-  Nessus validated all registry-based fixes  

## **9. Before vs After Comparison**

| Category | Before | After |
|----------|--------|--------|
| High Severity | **1** | **0** |
| Medium | Many | Reduced |
| Authenticode Validation | Missing | Enabled |
| CIS RDP NLA | Disabled | Enabled |
| System Security Posture | Weak | Improved |

---

## **10. Lessons Learned**
- Authenticated scans provide dramatically better visibility  
- Registry-based patches can close high-risk CVEs  
- CIS Benchmarks offer practical hardening steps  
- Nessus baselines + follow-up scans show measurable improvement  
- Vulnerability management is an iterative cycle of **scan → fix → verify**

---

## **11. Resume Summary**
- Performed an authenticated Nessus vulnerability assessment on Windows Server 2022  
- Identified and remediated High severity CVE-2013-3900  
- Applied CIS Benchmark hardening (Require NLA for RDP)  
- Validated remediation through a post-fix Nessus scan  
- Documented scan results, fixes, and security improvements

---

# **Project Structure**
```
/nessus-vulnerability-management/
│
├── README.md
├── report.md
│
├── assets/
│   ├── nessus-before/
│   ├── nessus-after/
│   ├── cve-2013-3900/
│   └── cis/
│
└── scripts/
    ├── enable-cert-padding.ps1
```

--_
