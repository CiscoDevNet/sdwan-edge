resource "openstack_compute_instance_v2" "cedge" {
  name      = var.name
  image_id  = data.openstack_images_image_v2.cedge.id
  flavor_id = data.openstack_compute_flavor_v2.cedge.id
  user_data = file("cloud-init/ciscosdwan_cloud_init.${var.name}.cfg")
  config_drive = true
  
  network {
    uuid = data.openstack_networking_network_v2.transport.id
    name = "transport"
  }

  network {
    uuid = data.openstack_networking_network_v2.service.id
    name = "service"
  }
}
