Configuration WindowsFirewallConfiguration {
	
	param
	(
		[parameter()]
		[string]
		$NodeName = 'localhost'
	)

	Import-DscResource -ModuleName PowerStig
	
	# Windows firewall version information
	$firewallStigVersion = '2.1'

	WindowsFirewall WindowsFirewallConfiguration {
		StigVersion = $firewallStigVersion
	}

}

WindowsFirewallConfiguration -Output "$env:windir\\Temp\\DSC-Configs\\WindowsFirewallConfiguration" | Out-Null