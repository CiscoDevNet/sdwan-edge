
variable "name" {}

variable "vsphere_server" {}
variable "vsphere_user" {}
variable "vsphere_password" {}

variable "datacenter" {}
variable "cluster" {}
variable "datastore" {}

variable "folder" {}
variable "template" {}
variable "vm_num_cpus" {
  type = number
}
variable "vm_memory" {
  type = number
}

variable "subnet_transport" {}
variable "subnet_service" {}


