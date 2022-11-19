packer {
	required_plugins {
		windows-update = {
			version = "0.14.1"
      		source = "github.com/rgl/windows-update"
		}
	}
}

source "vmware-iso" "vm"{
  boot_wait         = "6m"
  communicator      = "winrm"
  cpus              = 2
  disk_adapter_type = "lsisas1068"
  disk_size         = "${var.disk_size}"
  disk_type_id      = "${var.disk_type_id}"
  floppy_files      = [
	"${var.autounattend}",
  	"./Scripts/Set-NetworkTypeToPrivate.ps1",
	"./Scripts/ConfigureWinRM.ps1"
	]
  guest_os_type     = "windows9-64"
  network 			= "nat"
  headless          = "${var.headless}"
  iso_checksum      = "${var.iso_checksum}"
  iso_url           = "${var.iso_url}"
  memory            = "${var.memory}"
  shutdown_command  = "shutdown /s /t 10 /f /d p:4:1"
  version           = "${var.vmx_version}"
  vm_name           = "${var.vm_name}"
  vmx_data = {
    "RemoteDisplay.vnc.enabled" = "false"
    "RemoteDisplay.vnc.port"    = "5900"
  }
  vmx_remove_ethernet_interfaces = true
  vnc_port_max                   = 5980
  vnc_port_min                   = 5900
  winrm_password                 = "${var.winrm_password}"
  winrm_timeout                  = "${var.winrm_timeout}"
  winrm_username                 = "${var.winrm_username}"
}

build {
  sources = ["source.vmware-iso.vm"]

  provisioner "powershell" {
	scripts = [
		"./Scripts/Install-VMwareTools.ps1"
	]
  }

  provisioner "windows-update" {
	search_criteria = "IsInstalled=0"
  }

  post-processor "vagrant" {
    keep_input_artifact  = false
    output               = "windows10_{{ .Provider }}.box"
    vagrantfile_template = "VagrantFile"
  }
}
