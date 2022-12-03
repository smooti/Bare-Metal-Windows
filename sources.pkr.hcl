source "vmware-iso" "windows" {
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
  vmx_remove_ethernet_interfaces = true	# NOTE: For vagrant box
  vnc_port_max = 5980
  vnc_port_min = 5900

  # Optional vars
  boot_wait        = "6m"                            # NOTE This needs to be set as Windows takes longer to finish initialization
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1" # Graceful shutdown
  output_directory = "output-${var.os_name}"

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