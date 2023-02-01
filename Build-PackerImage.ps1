Import-Module '.\Scripts\Modules\vmdk.psm1'
$variableFile = '.\vars.pkrvars.hcl'
$step1Args = @{
	FilePath     = 'packer.exe'
	ArgumentList = "build -force -only=step1.vmware-iso.win10-iso --var-file=$($variableFile) ."
	wait         = $true
	NoNewWindow  = $true
}

$step2Args = @{
	FilePath     = 'packer.exe'
	ArgumentList = "build -force -only=step2.vmware-vmx.win10-vmx --var-file=$($variableFile) ."
	wait         = $true
	NoNewWindow  = $true
}

$step3Args = @{
	FilePath     = 'packer.exe'
	ArgumentList = "build -force -only=step3.vmware-vmx.win10-vmx --var-file=$($variableFile) ."
	wait         = $true
	NoNewWindow  = $true
}

$step4Args = @{
	FilePath     = 'packer.exe'
	ArgumentList = "build -force -only=step4.vmware-vmx.win10-vmx --var-file=$($variableFile) ."
	wait         = $true
	NoNewWindow  = $true
}

# Unpack and Setup Image
Start-Process @step1Args

# Provision Image
Start-Process @step2Args

# Update Image
Start-Process @step3Args

# Cleanup Image
Start-Process @step4Args

# Mount & Capture
$drive = (Get-ChildItem function:[d-z]: -n | Where-Object { !(Test-Path $_) })[0]	# NOTE: OSFMount uses the first unused drive letter
$emojiIcon = [System.Convert]::toInt32('1F604', 16) # Yes I am creating an emoji icon just for this...
$imagePath = "$PSScriptRoot\CapturedImage.wim"
Try {
	if (Test-Path $imagePath) {
		Write-Output 'Removing old image...'
		Remove-Item $imagePath -Force
	}

	$startTime = (Get-Date)

	Mount-vmdk -Path '.\output\step-4\disk-cl3.vmdk' | Out-Null
	Write-Output "Capturing image... ( Please be patient $([System.Char]::ConvertFromUtf32($emojiIcon)) this can take a while)"
	New-WindowsImage -ImagePath $imagePath -CapturePath $drive -Name $osData.name -CompressionType 'Max' -Verify

	$endTime = (Get-Date)
	$elapsedTime = $endTime - $startTime
	$elapsedMinutes = $elapsedTime.Minutes
	$elapsedSeconds = $elapsedTime.Seconds

	[string]::Format('==> Wait completed after {0} minutes {1} seconds', $elapsedMinutes, $elapsedSeconds)
	Write-Host '==> Wim file was successfully captured and written to disk at ' -NoNewline
	Write-Host "$imagePath" -ForegroundColor Cyan
}
Catch {
	Write-Warning 'An error occurred:'
	Write-Host $_
}
Finally {
	Dismount-vmdk -Drive $drive
}
