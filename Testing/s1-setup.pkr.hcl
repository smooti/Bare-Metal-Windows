source "vmware-iso" "win10-base" {
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

  # Machine information
  vm_name           = "${var.vm_name}"
  cpus              = "4"
  memory            = "6192"
  disk_adapter_type = "lsisas1068"
  disk_size         = "61440"
  guest_os_type     = "${var.guest_os_type}"
  headless          = "${var.headless}"
  # NOTE The autounattend file must be specified
  floppy_files = [
    "${var.autounattend}",
    "./Floppy/Set-NetworkTypeToPrivate.ps1",
    "./Floppy/Set-WinRMSettings.ps1"
  ]
}

build {
  name    = "${var.os_name}"
  sources = ["sources.vmware-iso.win10-base"]
}

variables {
  iso_url         = ""
  iso_checksum    = ""
  guest_os_type   = ""
  os_name         = ""
  autounattend    = "./Floppy/Answers/10/autounattend.xml"
  headless        = "true"
  vm_name         = "win10-base"
  vhv_enable      = "false"
  vmx_version     = "14"
  restart_timeout = "5m"
  winrm_password  = "1qaz2wsx!QAZ@WSX"
  winrm_timeout   = "3h"
  winrm_username  = "sap_admin"
}