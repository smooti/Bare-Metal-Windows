Configuration Windows10Stig
{
	param
	(
		[parameter()]
		[string]
		$NodeName = 'localhost'
	)

	Import-DscResource -ModuleName PowerStig
	# Internet explorer version information
	$ieStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'InternetExplorer' })[-1].Version
	$ieStigVersion = [string]($ieStigVersionObj).Major + '.' + [string]($ieStigVersionObj).Minor
	$ieVersion = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'InternetExplorer' })[-1].TechnologyVersion

	# Windows client version information
	$winClientStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq "WindowsClient" })[-1].Version
	$winClientStigVersion = [string]($winClientStigVersionObj).Major + '.' + [string]($winClientStigVersionObj).Minor
	$winClientVersion = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq "WindowsClient" })[-1].TechnologyVersion

	# Microsoft edge version information
	$edgeStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'MS' })[-1].Version
	$edgeStigVersion = [string]($edgeStigVersionObj).Major + '.' + [string]($edgeStigVersionObj).Minor

	# Microsoft dotnet version information
	$dotNetStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq "DotNetFramework" })[-1].Version
	$dotNetStigVersion = [string]($dotNetStigVersionObj).Major + '.' + [string]($dotNetStigVersionObj).Minor
	$dotNetVersion = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq "DotNetFramework" })[-1].TechnologyVersion

	# Windows Firewall version information
	$firewallStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'WindowsFirewall' })[-1].Version
	$firewallStigVersion = [string]($firewallStigVersionObj).Major + '.' + [string]($firewallStigVersionObj).Minor

	# Microsoft defender version information
	$defenderStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'WindowsDefender' })[-1].Version
	$defenderStigVersion = [string]($defenderStigVersionObj).Major + '.' + [string]($defenderStigVersionObj).Minor

	Node $NodeName
	{
		# InternetExplorer InternetExplorerSettings {
		# 	BrowserVersion = $ieVersion
		# 	Stigversion    = $ieStigVersion
		# }

		Edge MSEdge {
			StigVersion = $edgeStigVersion
			SkipRule    = @('V-235719')
		}

		DotNetFramework DotNetFrameworkSettings {
			FrameworkVersion = $dotNetVersion
			StigVersion      = $dotNetStigVersion
		}

		WindowsFirewall FirewallSettings {
			StigVersion = $firewallStigVersion
		}

		WindowsDefender DefenderSettings {
			StigVersion = $defenderStigVersion
		}

		# WindowsClient WindowsSettings {
		# 	OsVersion   = $winClientVersion
		# 	Stigversion = $winClientStigVersion
		# 	SkipRule    = @('V-220704', 'V-220903', 'V-220905', 'V-220906')
		# }
	}
}

Windows10Stig -OutputPath "..\Dsc\"

Start-DscConfiguration -Path "..\Dsc" -Wait -Force