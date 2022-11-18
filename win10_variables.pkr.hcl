variable "autounattend" {
  type    = string
  default = "./AnswerFiles/10/autounattend.xml"
}

variable "disk_size" {
  type    = string
  default = "61440"
}

variable "disk_type_id" {
  type    = string
  default = "1"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:2FD924BF87B94D2C4E9F94D39A57721AF9D986503F63D825E98CEE1F06C34F68"
}

variable "iso_url" {
  type    = string
  default = "./Distros/Win10_21H2_x64_English.ISO"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "restart_timeout" {
  type    = string
  default = "5m"
}

variable "vhv_enable" {
  type    = string
  default = "false"
}

variable "virtio_win_iso" {
  type    = string
  default = "./VirtDrivers/virtio-win-0.1.225.iso"
}

variable "vm_name" {
  type    = string
  default = "win10Ref"
}

variable "vmx_version" {
  type    = string
  default = "14"
}

variable "winrm_password" {
  type    = string
  default = "1qaz2wsx!QAZ@WSX"
}

variable "winrm_timeout" {
  type    = string
  default = "6h"
}

variable "winrm_username" {
  type    = string
  default = "sap_admin"
}