Configuration WindowsClientConfiguration {
	
	param
	(
		[parameter()]
		[string]
		$NodeName = 'localhost'
	)

	Import-DscResource -ModuleName PowerStig
	Import-DscResource -ModuleName PSDscResources

	# Windows client version information
	$winClientVersion = '10'
	$winClientStigVersion = '2.4'

	WindowsClient WindowsConfiguration {
		OsVersion   = $winClientVersion
		Stigversion = $winClientStigVersion
		SkipRule    = @(
			'V-220704', # NOTE: Use Bitlocker pin
			'V-220903', # NOTE: Skip certificate installation
			'V-220905', # NOTE: Skip certificate installation
			'V-220906', # NOTE: Skip certificate installation
			'V-220732', # NOTE: Disables secondary logon service (This must be enabled for packer to finish)
			'V-220968', # NOTE: Prevents local admin from remote access (This must be enabled for packer to finish)
			'V-220862', # NOTE: WinRM client basic auth (If not enabled vagrant will fail)
			'V-220865', # NOTE: WinRM service basic auth (If not enabled vagrant will fail)
			'V-220866', # NOTE: WinRM service unencrypted traffic (If not enabled vagrant will fail)
			'V-220863', # NOTE: WinRM client unencrypted traffic (If not enabled vagrant will fail)
			'V-220950', # NOTE: Remote UAC (If not enabled vagrant will fail)
			'V-220799', # NOTE: LocalAccountTokenFilterPolicy
			'V-220972'  # NOTE: Denies local account RDP access
			'V-220792', # NOTE: Not checked by SCAP tool
			'V-220793', # NOTE: Not checked by SCAP tool
			'V-220805', # NOTE: Not checked by SCAP tool
			'V-220811', # NOTE: Not checked by SCAP tool
			'V-220846', # NOTE: Not checked by SCAP tool
			'V-220861', # NOTE: Not checked by SCAP tool
			'V-220869', # NOTE: Not checked by SCAP tool
			'V-220872', # NOTE: Not checked by SCAP tool
			'V-220921', # NOTE: Not checked by SCAP tool
			'V-220922', # NOTE: Not checked by SCAP tool
			'V-220954', # NOTE: Not checked by SCAP tool
			'V-220955', # NOTE: Not checked by SCAP tool
			'V-252903'  # NOTE: Not checked by SCAP tool
		)
		SkipRuleType = @(
			'WindowsFeatureRule'
		)
	}

	WindowsOptionalFeature WindowsOptionalFeatureConfiguration {
		Name = 'MicrosoftWindowsPowerShellV2Root' # Windows Powershell v2
		NoWindowsUpdateCheck = $true
		RemoveFilesOnDisable = $false
		LogLevel = 'ErrorsAndWarning'
		Ensure = 'Absent'
	}

}

WindowsClientConfiguration -Output "$env:windir\\Temp\\DSC-Configs\\WindowsClientConfiguration" | Out-Null