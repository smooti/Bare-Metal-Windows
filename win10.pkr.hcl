packer {
  required_plugins {
    windows-update = {
      version = "0.14.1"
      source  = "github.com/rgl/windows-update"
    }
  }
}

source "vmware-iso" "vm" {
  # Required vars
  iso_checksum = "${var.iso_checksum}"
  iso_url      = "${var.iso_url}"

  # WinRM connection information
  communicator   = "winrm"
  winrm_password = "${var.winrm_password}"
  winrm_timeout  = "${var.winrm_timeout}"
  winrm_username = "${var.winrm_username}"

  # Allow vnc for debugging
  # NOTE Used for remote deployments
  vmx_data = {
    "RemoteDisplay.vnc.enabled" = "false"
    "RemoteDisplay.vnc.port"    = "5900"
  }
  vnc_port_max = 5980
  vnc_port_min = 5900

  # Optional vars
  boot_wait                      = "5m"                            # NOTE This needs to be set as Windows takes longer to finish initialization
  shutdown_command               = "shutdown /s /t 10 /f /d p:4:1" # Graceful shutdown
  vmx_remove_ethernet_interfaces = true                            # NOTE Only used for building vagrant box images

  # Machine information
  vm_name           = "${var.vm_name}"
  cpus              = "4"
  memory            = "6192"
  disk_adapter_type = "lsisas1068"
  disk_size         = "61440"
  guest_os_type     = "windows9-64"
  headless          = "${var.headless}"
  # NOTE The autounattend file must be specified
  floppy_files = [
    "${var.autounattend}",
    "./Floppy/Set-NetworkTypeToPrivate.ps1",
    "./Floppy/Set-WinRMSettings.ps1"
  ]
}

build {
  sources = ["source.vmware-iso.vm"]

  # Upload wallpapers
  provisioner "file" {
    source      = "Floppy/APL-Wallpapers"
    destination = "C:/windows/web/Wallpaper"
  }

  # Apply custom images
  provisioner "powershell" {
    scripts = [
      "./Scripts/Set-Wallpaper.ps1",
      "./Scripts/Set-UserImage.ps1"
    ]
  }

  # Force default user account image
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Setting default user account image...'",
      "New-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer' -Name 'UseDefaultTile' -PropertyType DWORD -Value '1' | Out-Null"
    ]
  }

  #   # Update Windows
  #   # NOTE: References for update GUIDS https://learn.microsoft.com/en-us/previous-versions/windows/desktop/ff357803(v=vs.85)
  #   provisioner "windows-update" {
  # 	search_criteria = "AutoSelectOnWebSites=1 and IsInstalled=0"
  # 	filters = [
  #       "exclude:$_.Title -like '*Preview*'",
  #       "include:$true"
  #     ]
  #     update_limit = 25
  #   }

  # Disable internet explorer & cortana
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Disabling Internet Explorer and Cortana...'",
      "Disable-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 -Online -NoRestart | Out-Null",
      "New-Item -Path 'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\' -Name 'Windows Search' | Out-Null",
      "New-ItemProperty -Path 'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Search' -Name 'AllowCortana' -PropertyType DWORD -Value '0' | Out-Null"
    ]
  }

  # Turn off weather and news on taskbar
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Turning off weather and news on taskbar...'",
      "Set-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Feeds' -Name 'ShellFeedsTaskbarViewMode' -Value '2' "
    ]
  }

  # Grab required modules
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Installing required packages...'",
      "Write-Host 'INFO: Installing NuGet Package...'",
      "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null", # Grab NuGet provider to interact with NuGet-based repositories
      "Write-Host 'INFO: Installing PSDscResources...'",
      "Install-Module PSDscResources -Force",
      "Write-Host 'INFO: Installing VMWare Power CLI...'",
      "Install-Module -Name VMWare.PowerCLI -SkipPublisherCheck -Force",
      "Write-Host 'INFO: Installing PowerStig...'",
      "Install-Module PowerStig -SkipPublisherCheck -Force"
    ]
  }

  #   # Update help information
  #   provisioner "powershell" {
  #     inline = [
  #       "Write-Host 'INFO: Grabbing latest help files for powershell modules...'",
  #       "Update-Help -UICulture en-us -ErrorAction Ignore -Force"
  #     ]
  #   }

  # Run scripts
  provisioner "powershell" {
    scripts = [
      "./Scripts/Debloat-Windows.ps1",
      "./Scripts/Install-VMwareTools.ps1",
      "./Scripts/Set-TLSSecureConfig.ps1",
      "./Scripts/Generate-STIG.ps1"
    ]
  }

  # Run DscConfiguration
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Initiating DSC configuration...'",
      "Start-DscConfiguration -Path \"$env:Userprofile\\Windows10Stig\" -Wait -Force"
    ]
  }

  # Creat vagrant box
  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "win10_{{ .Provider }}.box"
    vagrantfile_template = "VagrantFile"
  }
}
