Install-Module PSWindowsUpdate -MinimumVersion "2.2.0.3" -Force
Import-Module PSWindowsUpdate -Force

Get-WindowsUpdate -AcceptAll -Install