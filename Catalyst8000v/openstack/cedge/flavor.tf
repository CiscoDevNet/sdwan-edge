data "openstack_compute_flavor_v2" "cedge" {
  name = var.flavor_name
}