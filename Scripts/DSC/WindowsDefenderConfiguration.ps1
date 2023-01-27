Configuration WindowsDefenderConfiguration {
	
	param
	(
		[parameter()]
		[string]
		$NodeName = 'localhost'
	)

	Import-DscResource -ModuleName PowerStig

	# Windows defender version information
	$defenderStigVersion = '2.4'

	WindowsDefender WindowsDefenderConfiguration {
		StigVersion = $defenderStigVersion
	}

}

WindowsDefenderConfiguration -Output "$env:windir\\Temp\\DSC-Configs\\WindowsDefenderConfiguration" | Out-Null