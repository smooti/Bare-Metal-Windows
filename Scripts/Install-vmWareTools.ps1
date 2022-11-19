# Disable progress bar for fast downloads
$ProgressPreference = 'SilentlyContinue'
$vmToolsUrl = "https://packages.vmware.com/tools/esx/latest/windows/x64/"
$vmToolsExeName = ((Invoke-WebRequest -Uri $vmToolsUrl).Links | Where-Object {$_.href -like "VMware-tools-*-x86_64.exe"}).href
$vmToolsDlUrl = $vmToolsUrl + $vmToolsExeName
Invoke-Webrequest -Uri $vmToolsDlUrl -OutFile "$env:UserProfile\Downloads\$vmToolsExeName"