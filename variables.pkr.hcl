variable "iso_url" {
	type = string
	default = "./Distros/Win10_21H2_x64_English.ISO"
}

variable "iso_checksum" {
	type = string
	default = "sha256:2FD924BF87B94D2C4E9F94D39A57721AF9D986503F63D825E98CEE1F06C34F68"
}

variable "guest_os_type" {
	type = string
	default = "windows9-64"
}

variable "os_name" {
	type = string
	default = "win10"
}

variable "autounattend" {
	type = string
	default = "./Floppy/Answers/10/autounattend.xml"
}

variable "headless" {
	type = bool
	default = true
}

variable "vhv_enable" {
	type = bool
	default = false
}

variable "vmx_version" {
	type = number
	default = 14
}

variable "restart_timeout" {
	type = string
	default = "5m"
}

variable "winrm_timeout" {
	type = string
	default = "3h"
}

variable "winrm_username" {
	type = string
	default = "sap_admin"
}

variable "winrm_password" {
	type = string
	default = "1qaz2wsx!QAZ@WSX"
}
