data "google_compute_subnetwork" "transport" {
  name   = var.subnet_transport
  region = var.region
}

data "google_compute_subnetwork" "service" {
  name   = var.subnet_service
  region = var.region
}

resource "google_compute_route" "service-cloud" {
  name                   = "service-route-cloud-multicloud"
  dest_range             = "10.128.0.0/16"
  network                = data.google_compute_subnetwork.service.network
  next_hop_instance      = google_compute_instance.cedge.name
  next_hop_instance_zone = var.zone
  priority               = 500
}

resource "google_compute_route" "service-dc" {
  name                   = "service-route-dc-multicloud"
  dest_range             = "22.0.0.0/8"
  network                = data.google_compute_subnetwork.service.network
  next_hop_instance      = google_compute_instance.cedge.name
  next_hop_instance_zone = var.zone
  priority               = 500
}
