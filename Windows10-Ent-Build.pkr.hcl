packer {
  required_plugins {
    windows-update = {
      version = "0.14.1"
      source = "github.com/rgl/windows-update"
    }
  }
}

variable "iso_url" {
  type = string
}

variable "iso_checksum" {
  type = string
}

variable "os_name" {
  type = string
}

variable "guest_os_type" {
  type = string
}

variable "autounattend" {
  type    = string
  default = "./Answers/10/autounattend.xml"
}

variable "winrm_username" {
  type    = string
  default = "fire.keeper"
}

variable "winrm_password" {
  type    = string
  default = "1qaz2wsx!QAZ@WSX"
}

source "vmware-iso" "win10-iso" {

  # Required vars
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  boot_wait        = "3s"                            # NOTE This needs to be set as Windows takes longer to finish initialization
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1" # Graceful shutdown
  boot_command = [
    "<enter><enter>"
  ]

  # WinRM connection information
  communicator   = "winrm"
  winrm_username = "${var.winrm_username}"
  winrm_password = "${var.winrm_password}"
  winrm_timeout  = "3h"

  vmx_data = {
    "ehci.present" : "TRUE",
    "firmware" : "efi",
    "hpet0.present" : "TRUE",
    "ich7m.present" : "TRUE",
    "smc.present" : "TRUE"
  }

  # Machine information
  vm_name           = "${var.os_name}"
  cpus              = "2"
  memory            = "6192"
  cores             = "2"
  disk_adapter_type = "lsisas1068"
  disk_size         = "61440"
  guest_os_type     = "${var.guest_os_type}"
  headless          = false
  usb               = true
  cd_files = [
    "${var.autounattend}", # NOTE The autounattend file must be specified
    "./Scripts/Set-NetworkTypeToPrivate.ps1",
    "./Scripts/Set-WinRMSettings.ps1"
  ]
  cd_label = "cidata"
}

source "vmware-vmx" "win10-vmx" {

  # WinRM connection information
  communicator     = "winrm"
  shutdown_timeout = "1h"
  winrm_timeout    = "30m"
  winrm_username   = "${var.winrm_username}"
  winrm_password   = "${var.winrm_password}"
  vm_name          = "${var.os_name}"
  headless         = true
}

# Unpack and Setup Image
build {
  name = "step1"
  source "sources.vmware-iso.win10-iso" {
    output_directory = "output/step-1/"
  }
}

# Provision Image
# NOTE: OEM customizations and security settings
build {
  name = "step2"
  source "sources.vmware-vmx.win10-vmx" {
    source_path      = "output/step-1/${var.os_name}.vmx"
    output_directory = "output/step-2/"
	shutdown_command = "shutdown /s /t 10 /f /d p:4:1" # Graceful shutdown
  }

  provisioner "file" {
    source      = "Floppy/Images/wallpapers"
    destination = "C:/windows/web/wallpaper/Better-Images"
  }

  provisioner "file" {
    source      = "Floppy/Images/users"
    destination = "C:/windows/web/wallpaper/Better-Images"
  }

  provisioner "file" {
    source      = "Floppy/DoD_Root_Certificates.p7b"
    destination = "C:/windows/Temp/DoD_Root_Certificates.p7b"
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

  # Import DoD_Root_Certificates
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Installing DoD Root Certificates...'",
	  "Import-Certificate -FilePath \"$env:Windir/Temp/DoD_Root_Certificates.p7b\" -CertStoreLocation Cert:/LocalMachine/Root"
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
	  "./Scripts/Enable-RemoteDesktop.ps1",
      "./Scripts/DSC/LocalDSCConfig.ps1",
      "./Scripts/DSC/DotNetFrameworkConfiguration.ps1",
      "./Scripts/DSC/MicrosoftEdgeConfiguration.ps1",
      "./Scripts/DSC/WindowsDefenderConfiguration.ps1",
      "./Scripts/DSC/WindowsFirewallConfiguration.ps1",
      "./Scripts/DSC/WindowsClientConfiguration.ps1"
    ]
  }

  # Install VMwareTools
  provisioner "powershell" {
    only = ["vmware-vmx.win10-vmx"]
    scripts = [
      "./Scripts/Install-VMwareTools.ps1"
    ]
  }

  # Run DscConfiguration
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Initiating DSC configuration...'",
      "Set-DscLocalConfigurationManager -Path \"$env:windir\\Temp\\DSC-Configs\\LCMConfig\" -Force",
      "Publish-DscConfiguration -Path \"$env:windir\\Temp\\DSC-Configs\\DotNetFrameworkConfiguration\" -Force",
      "Publish-DscConfiguration -Path \"$env:windir\\Temp\\DSC-Configs\\MicrosoftEdgeConfiguration\" -Force",
      "Publish-DscConfiguration -Path \"$env:windir\\Temp\\DSC-Configs\\WindowsDefenderConfiguration\" -Force",
      "Publish-DscConfiguration -Path \"$env:windir\\Temp\\DSC-Configs\\WindowsFirewallConfiguration\" -Force",
      "Publish-DscConfiguration -Path \"$env:windir\\Temp\\DSC-Configs\\WindowsClientConfiguration\" -Force",
      "Start-DscConfiguration -UseExisting -Wait -Verbose"
    ]
  }

}

# Update Image
build {
  name = "step3"
  source "sources.vmware-vmx.win10-vmx" {
    source_path      = "output/step-2/${var.os_name}.vmx"
    output_directory = "output/step-3/"
	shutdown_command = "shutdown /s /t 10 /f /d p:4:1" # Graceful shutdown
  }

  # Update help information for powershell cmdlets
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Grabbing latest help files for powershell modules...'",
      "Update-Help -UICulture en-us -ErrorAction Ignore -Force"
    ]
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
}

# Finalize Image
build {
  name = "step4"
  source "sources.vmware-vmx.win10-vmx" {
    source_path                    = "output/step-3/${var.os_name}.vmx"
    output_directory               = "output/step-4/"
    vmx_remove_ethernet_interfaces = true
	shutdown_command = "C:\\Windows\\Temp\\Packer-Shutdown.cmd"
  }

  # Setup packer shutdown
  provisioner "file" {
	source = "Scripts\\Packer-Shutdown.cmd"
	destination = "C:\\Windows\\Temp\\Packer-Shutdown.cmd"
  }

  # Placing SetupComplete
  provisioner "file" {
	source = "Floppy\\SetupComplete.cmd"
	destination = "C:\\Windows\\Setup\\Scripts\\SetupComplete.cmd"
  }

  # Defrag cleanup
  provisioner "powershell" {
    inline = [
      "Write-Host 'INFO: Defragging Volume...'",
      "defrag.exe c: /U /V | Out-Null"
    ]
  }

}
