netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block

C:/windows/system32/sysprep/sysprep.exe /quiet /generalize /oobe /shutdown
