resource "null_resource" "iso" {

  triggers = {
    isofile = "cloud-init/${var.name}.iso"
  }
  provisioner "local-exec" {
    command = "mkisofs -l -o ${self.triggers.isofile} -volid cidata -joliet -rock cloud-init/ciscosdwan_cloud_init.cfg"
  }
  provisioner "local-exec" {
    when       = destroy
    command    = "rm ${self.triggers.isofile}"
    on_failure = continue
  }
}

resource "vsphere_file" "iso" {

  datacenter       = var.datacenter
  datastore        = var.datastore
  source_file      = null_resource.iso.triggers.isofile
  destination_file = "cloud-init_iso/${var.name}.iso"

  depends_on = [
    null_resource.iso
  ]
}