param(
	[switch]$SkipAtlas,
	[Parameter(Mandatory = $true)]
	[ValidateSet('Win10', 'Win2016StdCore')]
	$OSName
)

switch ($OSName) {
	'Win10' {
		$osData = @{
			os_name       = 'win10'
			guest_os_type = 'windows9-64'
			full_os_name  = 'Windows10'
			iso_checksum  = 'sha256:2FD924BF87B94D2C4E9F94D39A57721AF9D986503F63D825E98CEE1F06C34F68'
			iso_url       = './Distros/Win10_21H2_x64_English.ISO'
		}
	}

	'Win2016StdCore' {
		$osData = @{
			os_name       = 'win2016stdcore'
			guest_os_type = 'Windows2012_64'
			full_os_name  = 'Windows2016StdCore'
			iso_checksum  = '3bb1c60417e9aeb3f4ce0eb02189c0c84a1c6691'
			iso_url       = 'http://care.dlservice.microsoft.com/dl/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO'
		}
	}
}

# Base Image
Start-Process -FilePath 'packer.exe' -ArgumentList "build  -var `"os_name=$($osData.os_name)`" -var `"iso_checksum=$($osData.iso_checksum)`" -var `"iso_url=$($osData.iso_url)`" -var `"guest_os_type=$($osData.guest_os_type)`" Testing\s1-setup.pkr.hcl" -Wait -NoNewWindow

# # Installs Windows Updates and WMF5
# Start-Process -FilePath 'packer.exe' -ArgumentList "build  -var `"os_name=$($osData.os_name)`" -var `"source_path=.\output-$($osData.os_name)-base\$($osData.os_name)-base.ovf`" .\02-win_updates-wmf5.json" -Wait -NoNewWindow

# # Cleanup
# Start-Process -FilePath 'packer.exe' -ArgumentList "build  -var `"os_name=$($osData.os_name)`" -var `"source_path=.\output-$($osData.os_name)-updates_wmf5\$($osData.os_name)-updates_wmf5.ovf`" .\03-cleanup.json" -Wait -NoNewWindow

# # Vagrant Image Only
# Start-Process -FilePath 'packer.exe' -ArgumentList "build  -var `"os_name=$($osData.os_name)`" -var `"source_path=.\output-$($osData.os_name)-cleanup\$($osData.os_name)-cleanup.ovf`" .\04-local.json" -Wait -NoNewWindow