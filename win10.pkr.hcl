packer {
  required_plugins {
    windows-update = {
      version = "0.14.1"
      source  = "github.com/rgl/windows-update"
    }
  }
}

source "vmware-iso" "win10" {
  # Required vars
  iso_checksum = "${var.iso_checksum}"
  iso_url      = "${var.iso_url}"

  # WinRM connection information
  communicator   = "winrm"
  winrm_username = "${var.winrm_username}"
  winrm_password = "${var.winrm_password}"
  winrm_timeout  = "${var.winrm_timeout}"

  # Allow vnc for debugging
  # NOTE Used for remote deployments
  vmx_data = {
    "RemoteDisplay.vnc.enabled" = "true"
    "RemoteDisplay.vnc.port"    = "5900"
  }
  vnc_port_max = 5980
  vnc_port_min = 5900

  # Optional vars
  boot_wait        = "6m"                            # NOTE This needs to be set as Windows takes longer to finish initialization
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1" # Graceful shutdown

  # Machine information
  vm_name           = "${var.os_name}"
  cpus              = "4"
  memory            = "6192"
  disk_adapter_type = "lsisas1068"
  disk_size         = "61440"
  guest_os_type     = "${var.guest_os_type}"
  headless          = "${var.headless}"
  floppy_files = [
    "${var.autounattend}", # NOTE The autounattend file must be specified
    "./Floppy/Set-NetworkTypeToPrivate.ps1",
    "./Floppy/Set-WinRMSettings.ps1"
  ]
}

build {
  sources = ["source.vmware-iso.win10"]


  # SECTION: Setup
  # Upload wallpapers
  provisioner "file" {
    source      = "Floppy/APL-Wallpapers"
    destination = "C:/windows/web/Wallpaper"
  }
  # !SECTION: Setup

  # SECTION - Provisioning
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

  # Install VMwareTools
  provisioner "powershell" {
    only = ["vmware-iso.win10"]
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
  # !SECTION - Provisioning

  # SECTION - Updates
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

  #   # Update help information for powershell cmdlets
  #   provisioner "powershell" {
  #     inline = [
  #       "Write-Host 'INFO: Grabbing latest help files for powershell modules...'",
  #       "Update-Help -UICulture en-us -ErrorAction Ignore -Force"
  #     ]
  #   }
  # !SECTION - Updates

  #   # NOTE: Reboot needed for sysprep to work
    # provisioner "windows-restart" {}

  #   # Sysprep and generalize image
  #   provisioner "powershell" {
  #     inline = [
  #       "Write-Host 'INFO: Generalizing image...'",
  # 	  "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /quiet /generalize /oobe /quit",
  #       "while($true) { $imageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select ImageState; if($imageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $imageState.ImageState; Start-Sleep -s 10  } else { break } }"
  #     ]
  #   }

  # Creat vagrant box
  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "win10_{{ .Provider }}.box"
    vagrantfile_template = "VagrantFile"
  }
}
