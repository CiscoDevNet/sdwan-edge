data "openstack_networking_network_v2" "transport" {
  name = var.subnet_transport
}

data "openstack_networking_network_v2" "service" {
  name = var.subnet_service
}