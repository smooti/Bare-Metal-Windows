$ProgressPreference = 'SilentlyContinue'
# Install ADK
# NOTE: ADK for windows 10 version 2004
$adkUri = 'https://go.microsoft.com/fwlink/?linkid=2120254'
$adkFileName = 'adk.exe'
Invoke-WebRequest -Uri $adkUri -OutFile $adkFileName
& $adkFileName /quiet

# Install MDT
$mdtUri = 'https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi'
$mdtFileName = 'mdt.msi'
Invoke-WebRequest -Uri $mdtUri -OutFile $mdtFileName
msiexec.exe /i $mdtFileName /quiet /qn
Import-Module 'C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1'

$driveParameters = @{
	Name        = 'DS002'
	PSProvider  = 'MDTProvider'
	Root        = 'C:\DeploymentShare'
	Description = 'MDT Deployment Share'
	NetworkPath = "\\$($env:ComputerName)\DeploymentShare1$"
}

New-PSDrive @driveParameters -Verbose | Add-MDTPersistentDrive -Verbose

$tsParams = @{
	Path          = 'DS002:\Task Sequences'
	Name          = 'Sysprep & Capture'
	Template      = 'CaptureOnly.xml'
	Comments      = 'This will sysprep and capture an image'
	ID            = 'SysCap'
	Version       = '1.0'
	AdminPassword = '1qaz2wsx!QAZ@WSX'
}

Import-mdttasksequence @tsParams
