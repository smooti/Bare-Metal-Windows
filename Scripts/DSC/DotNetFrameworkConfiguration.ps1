Configuration DotNetFrameworkConfiguration {
	
	param
	(
		[parameter()]
		[string]
		$NodeName = 'localhost'
	)

	Import-DscResource -ModuleName PowerStig

	# DotNetFramework version information
	$dotNetFrameworkStigVersion = '2.1'
	$dotNetFrameworkVersion = '4'

	DotNetFramework DotNetFrameworkConfiguration {
		FrameworkVersion = $dotNetFrameworkVersion
		StigVersion      = $dotNetFrameworkStigVersion
	}

}

DotNetFrameworkConfiguration -Output "$env:windir\\Temp\\DSC-Configs\\DotNetFrameworkConfiguration" | Out-Null