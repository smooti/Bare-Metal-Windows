Configuration MicrosoftEdgeConfiguration {
	
	param
	(
		[parameter()]
		[string]
		$NodeName = 'localhost'
	)

	Import-DscResource -ModuleName PowerStig

	# Microsoft edge version information
	$edgeStigVersion = '1.5'

	Edge MicrosoftEdgeConfiguration {
		StigVersion = $edgeStigVersion
		SkipRule    = @(
			'V-235719' # NOTE: User control of proxy settings must be disabled
		)
		Exception   = @{'V-235752' = @{'ValueData' = '1' } } # NOTE: Default is '2' which blocks almost all downloads
	}

}

MicrosoftEdgeConfiguration -Output "$env:windir\\Temp\\DSC-Configs\\MicrosoftEdgeConfiguration" | Out-Null