[DSCLocalConfigurationManager()]
configuration LCMConfig
{
    Node localhost
    {
        Settings
        {
            RefreshMode = 'Push'
			ConfigurationMode = 'ApplyOnly'
        }

		PartialConfiguration DotNetFrameworkConfiguration
		{
			Description = 'DotNetFramework configuration'
            RefreshMode = 'Push'
		}

		PartialConfiguration WindowsFirewallConfiguration
		{
			Description = 'WindowsFirewall configuration'
            RefreshMode = 'Push'
		}

		PartialConfiguration MicrosoftEdgeConfiguration
		{
			Description = 'Microsoft Edge configuration'
            RefreshMode = 'Push'
		}

		PartialConfiguration WindowsDefenderConfiguration
		{
			Description = 'WindowsDefender configuration'
            RefreshMode = 'Push'
		}

		PartialConfiguration WindowsClientConfiguration
		{
			Description = 'WindowsClient configuration'
            RefreshMode = 'Push'
		}
    }
}

LCMConfig -Output "$env:windir\\Temp\\DSC-Configs\\LCMConfig" | Out-Null