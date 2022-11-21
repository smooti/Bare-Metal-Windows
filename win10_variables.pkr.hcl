# Main vars
variable "autounattend" {
  type    = string
  default = "./Answers/10/autounattend.xml"
}

variable "iso_url" {
  type    = string
  default = "./Distros/Win10_21H2_x64_English.ISO"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:2FD924BF87B94D2C4E9F94D39A57721AF9D986503F63D825E98CEE1F06C34F68"
}

# Hardware information
variable "vm_name" {
  type    = string
  default = "win10Ref"
}

variable "guest_os_type" {
  type    = string
  default = "windows9-64"
}

variable "cpu" {
  type    = string
  default = "4"
}

variable "memory" {
  type    = string
  default = "6192"
}

variable "disk_size" {
  type    = string
  default = "61440"
}

# Other information
variable "headless" {
  type    = string
  default = "false"
}

variable "vhv_enable" {
  type    = string
  default = "false"
}

variable "vmx_version" {
  type    = string
  default = "14"
}


variable "restart_timeout" {
  type    = string
  default = "5m"
}

# Connection information
variable "winrm_password" {
  type    = string
  default = "1qaz2wsx!QAZ@WSX"
}

variable "winrm_timeout" {
  type    = string
  default = "3h"
}

variable "winrm_username" {
  type    = string
  default = "sap_admin"
}
