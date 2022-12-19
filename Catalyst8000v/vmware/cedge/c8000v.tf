data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "cedge" {
  name              = var.name
  resource_pool_id  = data.vsphere_compute_cluster.cluster.resource_pool_id
  folder            = var.folder
  datastore_id      = data.vsphere_datastore.ds.id

  num_cpus          = var.vm_num_cpus
  memory            = var.vm_memory
  guest_id          = data.vsphere_virtual_machine.template.guest_id
  scsi_type         = data.vsphere_virtual_machine.template.scsi_type

#  ignored_guest_ips = ["127.1.0.1"]
  wait_for_guest_net_routable = false

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  } 


  cdrom {
    datastore_id = data.vsphere_datastore.ds.id
    path         = "cloud-init_iso/${var.name}.iso"
 }

  network_interface {
      network_id   = data.vsphere_network.transport.id
  }
  network_interface {
      network_id   = data.vsphere_network.service.id
  }


  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  depends_on = [
    vsphere_file.iso
  ]
}
