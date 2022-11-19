<# SECTION Download STIG GPO zip#>
# Disable progress bar for fast downloads
$ProgressPreference = 'SilentlyContinue'
$gpoUrl = "https://public.cyber.mil/stigs/gpo/"
$workSpace = "$env:UserProfile\Downloads\GPOs"
<# NOTE "-UseBasicParsing" must be used if a machine either does not have IE or has not yet run the initial setup for IE #>
$gpoZipName = "U_STIG_GPO.zip"
$cyberExchangeGpoDlUrl = ((Invoke-WebRequest -Uri $gpoUrl -UseBasicParsing).Links | Where-Object {$_.href -like "*U_*_STIG_GPO.zip"}).href
$gpoLocalZipLocation = "$env:UserProfile\Downloads\$gpoZipName"
Invoke-Webrequest -Uri $cyberExchangeGpoDlUrl -OutFile $gpoLocalZipLocation -UseBasicParsing
<# !SECTION Download STIG GPO zip#>

<# SECTION Unzip file#>
Expand-Archive -Path $gpoLocalZipLocation -DestinationPath $workSpace
<# !SECTION Unzip file#>