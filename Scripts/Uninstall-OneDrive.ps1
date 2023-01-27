Write-Output 'Uninstalling OneDrive.'
    
New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
$ExplorerReg1 = 'HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}'
$ExplorerReg2 = 'HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}'
Stop-Process -Name 'OneDrive*'
Start-Sleep 2
If (!(Test-Path $onedrive)) {
	$onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
}

Start-Process $onedrive '/uninstall' -NoNewWindow -Wait
Start-Sleep 2
Write-Output 'Stopping explorer'
Start-Sleep 1
Stop-Process -Name 'explorer' -Force
Start-Sleep 3
Write-Output 'Removing leftover files'
Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse
Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse
Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse
If (Test-Path "$env:SYSTEMDRIVE\OneDriveTemp") {
	Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse
}

Write-Output 'Removing OneDrive from windows explorer'
If (!(Test-Path $ExplorerReg1)) {
	New-Item $ExplorerReg1 | Out-Null
}

Set-ItemProperty $ExplorerReg1 System.IsPinnedToNameSpaceTree -Value 0 
If (!(Test-Path $ExplorerReg2)) {
	New-Item $ExplorerReg2 | Out-Null
}

Set-ItemProperty $ExplorerReg2 System.IsPinnedToNameSpaceTree -Value 0
Start-Process 'explorer' -NoNewWindow
