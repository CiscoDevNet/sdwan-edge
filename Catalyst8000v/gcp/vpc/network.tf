resource "google_compute_network" "transport" {
  name = "sdwan-transport-network"
  auto_create_subnetworks = false
}

resource "google_compute_network" "service" {
  name = "sdwan-service-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "transport" {
  name                     = "sdwan-transport-subnet"
  ip_cidr_range            = var.subnet_transport_prefix
  network                  = google_compute_network.transport.id
  region                   = var.region
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "service" {
  name                     = "sdwan-service-subnet"
  ip_cidr_range            = var.subnet_service_prefix
  network                  = google_compute_network.service.id
  region                   = var.region
  private_ip_google_access = true
}
