source "vsphere-iso" "cedge" {
  CPUs                = var.vm_cpu_num
  RAM                 = var.vm_mem_size
  boot_wait           = "2s"
  boot_command        = ["<wait2m>"]
  cluster             = var.vsphere_cluster
  convert_to_template = true
  datacenter          = var.vsphere_datacenter
  datastore           = var.vsphere_datastore
  firmware            = "bios"
  folder              = var.vsphere_folder
  guest_os_type       = "otherGuest"
  insecure_connection = "true"
  iso_checksum        = var.iso_checksum
  iso_urls            = [var.iso_url]
  network_adapters {
    network      = var.vsphere_network
    network_card = "vmxnet3"
  }
  network_adapters {
    network      = var.vsphere_network
    network_card = "vmxnet3"
  }
  storage {
    disk_size             = var.os_disk_size
    disk_thin_provisioned = var.disk_thin_provision
  }
  username       = var.vsphere_user
  password       = var.vsphere_password
  vcenter_server = var.vsphere_server
  vm_name        = var.vm_name

  ssh_username   = "root"
  communicator   = "none"
}

build {
  sources = ["source.vsphere-iso.cedge"]
}
