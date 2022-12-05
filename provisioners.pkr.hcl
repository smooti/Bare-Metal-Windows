build {
  sources = ["source.vmware-iso.windows"]

  // SECTION: Setup & Update//
  # Upload wallpapers
  provisioner "file" {
    source      = "Floppy/APL-Wallpapers"
    destination = "C:/windows/web/Wallpaper"
  }

  # Update Windows
  # NOTE: References for update GUIDS https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ff357803(v=vs.85)
  provisioner "windows-update" {
    search_criteria = "AutoSelectOnWebSites=1 and IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 25
  }

  # Update help information for powershell cmdlets
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Grabbing latest help files for powershell modules...'",
      "Update-Help -UICulture en-us -ErrorAction Ignore -Force"
    ]
  }
  // !SECTION: Setup & Update//

  // SECTION - Provisioning //
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Setting default user account image...'",
      "New-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer' -Name 'UseDefaultTile' -PropertyType DWORD -Value '1' | Out-Null",
      "",
      "Write-Host 'INFO: Disabling Internet Explorer and Cortana...'",
      "Disable-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 -Online -NoRestart | Out-Null",
      "New-Item -Path 'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\' -Name 'Windows Search' | Out-Null",
      "New-ItemProperty -Path 'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Search' -Name 'AllowCortana' -PropertyType DWORD -Value '0' | Out-Null",
      "",
      "Write-Host 'INFO: Turning off weather and news on taskbar...'",
      "Stop-Process -Name 'explorer' -Force",
      "Set-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Feeds' -Name 'ShellFeedsTaskbarViewMode' -Value '2'",
      "Start-Process 'explorer'",
      "",
      "Write-Host 'INFO: Turning off hibernation feature...'",
      "powercfg -h off"
    ]
  }

  # Grab required modules
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Installing required packages...'",
      "",
      "Write-Host 'INFO: Installing NuGet Package...'",
      "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null", # Grab NuGet provider to interact with NuGet-based repositories
      "",
      "Write-Host 'INFO: Installing PSDscResources...'",
      "Install-Module PSDscResources -Force",
      "",
      "Write-Host 'INFO: Installing VMWare Power CLI...'",
      "Install-Module -Name VMWare.PowerCLI -SkipPublisherCheck -Force",
      "",
      "Write-Host 'INFO: Installing PowerStig...'",
      "Install-Module PowerStig -SkipPublisherCheck -Force"
    ]
  }

  # Run scripts
  provisioner "powershell" {
    scripts = [
      "./Scripts/Set-Wallpaper.ps1",
      "./Scripts/Set-UserImage.ps1",
      "./Scripts/Debloat-Windows.ps1",
      "./Scripts/Uninstall-OneDrive.ps1",
      "./Scripts/Set-TLSSecureConfig.ps1",
      "./Scripts/Generate-STIG.ps1"
    ]
  }

#   # Install VMwareTools
#   provisioner "powershell" {
#     only = ["vmware-iso.windows"]
#     scripts = [
#       "./Scripts/Install-VMwareTools.ps1"
#     ]
#   }

  // FIXME: A setting is being applied causing packer to fail //
  # Run DscConfiguration
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Initiating DSC configuration...'",
      "Start-DscConfiguration -Path \"$env:Userprofile\\Windows10Stig\" -Wait -Force"
    ]
  }

  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "win10_{{ .Provider }}.box"
    vagrantfile_template = "VagrantFile"
  }
  // SECTION - Provisioning //

}