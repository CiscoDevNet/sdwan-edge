data "vsphere_network" "transport" {
  name          = var.subnet_transport
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "service" {
  name          = var.subnet_service
  datacenter_id = data.vsphere_datacenter.dc.id
}

