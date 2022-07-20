data "google_compute_subnetwork" "transport" {
  name   = var.subnet_transport
  region = var.region
}

data "google_compute_subnetwork" "service" {
  name   = var.subnet_service
  region = var.region
}