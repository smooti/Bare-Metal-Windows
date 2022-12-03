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

	# Google Chrome version information
	$googleChromeStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.TechnologyVersion -eq 'Chrome' })[-1].Version
	$googleChromeStigVersion = [string]($googleChromeStigVersionObj).Major + '.' + [string]($googleChromeStigVersionObj).Minor
	$googleChromeVersion = (Get-Stig -ListAvailable | Where-Object { $_.TechnologyVersion -eq 'Chrome' })[-1].TechnologyVersion

	# Firefox version information
	$firefoxStigVersionObj = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'FireFox' })[-1].Version
	$firefoxStigVersion = [string]($firefoxStigVersionObj).Major + '.' + [string]($firefoxStigVersionObj).Minor
	$fireFoxVersion = (Get-Stig -ListAvailable | Where-Object { $_.Technology -eq 'FireFox' })[-1].TechnologyVersion

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

		Edge MSEdgeSettings {
			StigVersion = $edgeStigVersion
			SkipRule    = @(
				'V-235719' # NOTE: User control of proxy settings must be disabled
			)
			Exception   = @{'V-235752' = @{'ValueData' = '1' } } # NOTE: Default is '2' which blocks almost all downloads
		}

		Firefox FirefoxSettings {
			StigVersion = $firefoxStigVersion
		}

		Google GoogleChromeSettings {
			StigVersion = $googleChromeStigVersion
			BrowserVersion = $googleChromeVersion
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
				'V-220950', # NOTE: Remote UAC (If not enabled vagrant will fail)
				'V-220799', # NOTE: LocalAccountTokenFilterPolicy
				'V-220739', # FIXME: Skip lockout duration because keeps failing
				'V-220740', # FIXME: Skip lockout threshold because keeps failing
				'V-220741'  # FIXME: Skip Reset_account_lockout_counter because keeps failing
				# 'V-220718'  # FIXME: Checks if IIS is installed Get-DSCConfiguration will fail when it checks for this setting
			)
			SkipRuleType = @(
				'WindowsFeatureRule'
			# 	'RegistryRule'
			)
		}
		
		Adobe AcrobatReaderSettings {
			StigVersion = $acroReaderStigVersion
			AdobeApp    = $acroReaderVersion
		}
	}
}

Windows10Stig | Out-Null
