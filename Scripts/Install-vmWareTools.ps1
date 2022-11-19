<# SECTION Download and install 7-zip #>
if (!( Test-Path "$env:windir\Temp\7z1900-x64.msi")) {
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	(New-Object System.Net.WebClient).DownloadFile('https://www.7-zip.org/a/7z1900-x64.msi', "$env:windir\Temp\7z1900-x64.msi")
}

if (!(Test-Path "$env:windir\Temp\7z1900-x64.msi")) {
	Start-Sleep 5
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	(New-Object System.Net.WebClient).DownloadFile('https://www.7-zip.org/a/7z1900-x64.msi', "$env:windir\Temp\7z1900-x64.msi")
}

msiexec /qb /i "$env:windir\Temp\7z1900-x64.msi"
<# !SECTION Download and install 7-zip #>

<# SECTION Download latest VMwareTools #>
Try {
	# Disabling the progress bar speeds up IWR https://github.com/PowerShell/PowerShell/issues/2138
	$ProgressPreference = 'SilentlyContinue'
	$pageContentLinks = (Invoke-WebRequest('https://softwareupdate.vmware.com/cds/vmw-desktop/ws') -UseBasicParsing).Links | Where-Object { $_.href -Match "[0-9]" } | Select-Object href | ForEach-Object { $_.href.Trim('/') }
	$versionObject = $pageContentLinks | ForEach-Object { New-Object System.Version ($_) } | Sort-Object -Descending | Select-Object -First 1 -Property:Major, Minor, Build
	$newestVersion = $versionObject.Major.ToString() + "." + $versionObject.Minor.ToString() + "." + $versionObject.Build.ToString() | Out-String
	$newestVersion = $newestVersion.TrimEnd("`r?`n")

	$nextURISubdirectoryObject = (Invoke-WebRequest("https://softwareupdate.vmware.com/cds/vmw-desktop/ws/$newestVersion/") -UseBasicParsing).Links | Where-Object { $_.href -Match "[0-9]" } | Select-Object href | Where-Object { $_.href -Match "[0-9]" }
	$nextUriSubdirectory = $nextURISubdirectoryObject.href | Out-String
	$nextUriSubdirectory = $nextUriSubdirectory.TrimEnd("`r?`n")
	$newestVMwareToolsURL = "https://softwareupdate.vmware.com/cds/vmw-desktop/ws/$newestVersion/$nextURISubdirectory/windows/packages/tools-windows.tar"
	Write-Output "The latest version of VMware tools has been determined to be downloadable from $newestVMwareToolsURL"
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	(New-Object System.Net.WebClient).DownloadFile("$newestVMwareToolsURL", "$env:windir\Temp\vmware-tools.tar")
}
Catch {
	Write-Output "Unable to determine the latest version of VMware tools. Falling back to hardcoded URL."
	(New-Object System.Net.WebClient).DownloadFile('https://softwareupdate.vmware.com/cds/vmw-desktop/ws/15.5.5/16285975/windows/packages/tools-windows.tar', "$env:windir\Temp\vmware-tools.tar")
}
<# !SECTION Download latest VMwareTools #>

<# SECTION  Unpack and setup VMwareTools install #>
cmd /c "$env:ProgramFiles\7-Zip\7z.exe" x $env:ProgramFiles\Temp\vmware-tools.tar -o $env:ProgramFiles\Temp
Move-Item $env:ProgramFiles\temp\VMware-tools-windows-*.iso $env:ProgramFiles\temp\windows.iso
Try {
	Remove-Item "C:\Program Files\VMWare" -Recurse -Force -ErrorAction Stop
}
Catch {
	Write-Output "Directory didn't exist to be removed."
}

cmd /c "$env:ProgramFiles\7-Zip\7z.exe" x "$env:windir\Temp\windows.iso" -o $env:ProgramFiles\Temp\VMWare
<# !SECTION  Unpack and setup VMwareTools install #>

# Install VMware Tools
cmd /c $env:ProgramFiles\Temp\VMWare\setup64.exe /S /v"/qn REBOOT=R\"

<# SECTION Install cleanup #>
Remove-Item -Force "$env:windir\Temp\vmware-tools.tar"
Remove-Item -Force "$env:windir\Temp\windows.iso"
Remove-Item -Force -Recurse "$env:windir\Temp\VMware"
<# !SECTION Install cleanup #>

cmd /c msiexec /qb /x $env:ProgramFiles\Temp\7z1900-x64.msi