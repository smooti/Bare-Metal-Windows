packer {
  required_plugins {
    windows-update = {
      version = "0.14.1"
      source  = "github.com/rgl/windows-update"
    }
  }
}

source "vmware-vmx" "win10-updates" {
  source_path      = "${var.source_path}"
  vm_name = "${var.os_name}-updates"

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
  sources = ["sources.vmware-vmx.win10-updates"]

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

variables {
  source_path    = ""
  os_name        = ""
  headless       = "true"
  winrm_password = "1qaz2wsx!QAZ@WSX"
  winrm_timeout  = "3h"
  winrm_username = "sap_admin"
}