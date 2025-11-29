This is the code we used to patch the vulnerability

reg add "HKLM\Software\Microsoft\Cryptography\Wintrust\Config" /v EnableCertPaddingCheck /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config" /v EnableCertPaddingCheck /t REG_DWORD /d 1 /f

