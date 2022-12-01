source "vmware-vmx" "win10-provisioned" {
  source_path = "${var.source_path}"

  # WinRM connection information
  communicator     = "winrm"
  winrm_password   = "${var.winrm_password}"
  winrm_timeout    = "${var.winrm_timeout}"
  winrm_username   = "${var.winrm_username}"
  headless         = "${var.headless}"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1" # Graceful shutdown
  # Allow vnc for debugging
  # NOTE Used for remote deployments
  vmx_data = {
    "RemoteDisplay.vnc.enabled" = "false"
    "RemoteDisplay.vnc.port"    = "5900"
  }
  vnc_port_max = 5980
  vnc_port_min = 5900
}

build {
  sources = ["sources.vmware-vmx.updates"]

  # Upload wallpapers
  provisioner "file" {
    source      = "Floppy/APL-Wallpapers"
    destination = "C:/windows/web/Wallpaper"
  }

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

  #   # Update help information for powershell cmdlets
  #   provisioner "powershell" {
  #     inline = [
  #       "Write-Host 'INFO: Grabbing latest help files for powershell modules...'",
  #       "Update-Help -UICulture en-us -ErrorAction Ignore -Force"
  #     ]
  #   }

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

  # Install VMwareTools
  provisioner "powershell" {
    only = ["vmware-iso.vm"]
    scripts = [
      "./Scripts/Install-VMwareTools.ps1"
    ]
  }

  # FIXME: A setting is being applied causing packer to fail
  # Run DscConfiguration
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Initiating DSC configuration...'",
      "Start-DscConfiguration -Path \"$env:Userprofile\\Windows10Stig\" -Wait -Force"
    ]
  }

}

variables {
  source_path    = ""
  os_name        = ""
  headless       = "true"
  winrm_password = "1qaz2wsx!QAZ@WSX"
  winrm_timeout  = "3h"
  winrm_username = "sap_admin"
}