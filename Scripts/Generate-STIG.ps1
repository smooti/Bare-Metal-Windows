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
	$winClientStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'WindowsClient' })[-1].Version
	$winClientStigVersion = [string]($winClientStigVersionObj).Major + '.' + [string]($winClientStigVersionObj).Minor
	$winClientVersion = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'WindowsClient' })[-1].TechnologyVersion

	# Microsoft edge version information
	$edgeStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'MS' })[-1].Version
	$edgeStigVersion = [string]($edgeStigVersionObj).Major + '.' + [string]($edgeStigVersionObj).Minor

	# Microsoft dotnet version information
	$dotNetStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'DotNetFramework' })[-1].Version
	$dotNetStigVersion = [string]($dotNetStigVersionObj).Major + '.' + [string]($dotNetStigVersionObj).Minor
	$dotNetVersion = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'DotNetFramework' })[-1].TechnologyVersion

	# Windows Firewall version information
	$firewallStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'WindowsFirewall' })[-1].Version
	$firewallStigVersion = [string]($firewallStigVersionObj).Major + '.' + [string]($firewallStigVersionObj).Minor

	# Microsoft defender version information
	$defenderStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'WindowsDefender' })[-1].Version
	$defenderStigVersion = [string]($defenderStigVersionObj).Major + '.' + [string]($defenderStigVersionObj).Minor

	# Microsoft defender version information
	$acroReaderStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.TechnologyVersion -eq 'AcrobatReader' })[-1].Version
	$acroReaderStigVersion = [string]($acroReaderStigVersionObj).Major + '.' + [string]($acroReaderStigVersionObj).Minor
	$acroReaderVersion = (Get-Stig -ListAvailable | Where-Object { $_.TechnologyVersion -eq 'AcrobatReader' })[-1].TechnologyVersion

	Node $NodeName
	{
		# # FIXME: Some settings overlap with microsoft edge causing issues with applying DSC
		# InternetExplorer InternetExplorerSettings {
		# 	BrowserVersion = $ieVersion
		# 	Stigversion    = $ieStigVersion
		# }

		Edge MSEdge {
			StigVersion = $edgeStigVersion
			SkipRule    = @(
				'V-235719' # NOTE: User control of proxy settings must be disabled
			)
			Exception   = @{'V-235752' = @{'ValueData' = '1' } } # NOTE: Default is '2' which blocks almost all downloads
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

		# NOTE: Packer uses the 'secondary logon service' along with 'winRM' to send commands to the image
		WindowsClient WindowsSettings {
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
				'V-220868', # NOTE: WinRM client Digest Authentication (If not enabled vagrant will fail)
				'V-220867'  # NOTE: WinRM service run-as credentials (If not enabled vagrant will fail)
				'V-220739', # FIXME: Skip lockout duration because keeps failing
				'V-220740', # FIXME: Skip lockout threshold because keeps failing
				'V-220741'  # FIXME: Skip Reset_account_lockout_counter because keeps failing
			)
		}
		
		Adobe AcrobatReaderSettings {
			StigVersion = $acroReaderStigVersion
			AdobeApp    = $acroReaderVersion
		}
	}
}

Windows10Stig | Out-Null
