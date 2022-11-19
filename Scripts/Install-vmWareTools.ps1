# Disable progress bar for fast downloads
$ProgressPreference = 'SilentlyContinue'
$vmToolsUrl = "https://packages.vmware.com/tools/esx/latest/windows/x64/"
<# NOTE "-UseBasicParsing" must be used if a machine either does not have IE or has not yet run the initial setup for IE #>
$vmToolsExeName = ((Invoke-WebRequest -Uri $vmToolsUrl -UseBasicParsing).Links | Where-Object {$_.href -like "VMware-tools-*-x86_64.exe"}).href
$vmToolsDlUrl = $vmToolsUrl + $vmToolsExeName
$vmToolslocalFile = "$env:UserProfile\Downloads\$vmToolsExeName"

Invoke-Webrequest -Uri $vmToolsDlUrl -OutFile $vmToolslocalFile -UseBasicParsing
& $vmToolslocalFile /S /v/qn REBOOT=R
Remove-Item $vmToolslocalFile -Force