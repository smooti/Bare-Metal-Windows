Stop-Service -Name "wuauserv"
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name "EnableFeaturedSoftware" -PropertyType DWORD -Value 1
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name "IncludeRecommendedUpdates" -PropertyType DWORD -Value 1

# Register the Microsoft Update service with Automatic Updates
Write-Output Set ServiceManager = CreateObject("Microsoft.Update.ServiceManager") > A:\temp.vbs
Write-Output Set NewUpdateService = ServiceManager.AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "") >> A:\temp.vbs

cscript A:\temp.vbs

Start-Service -Name "wuauserv"
