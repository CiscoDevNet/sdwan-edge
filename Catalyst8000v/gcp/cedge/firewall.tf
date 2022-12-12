resource "google_compute_firewall" "transport" {
  name    = "sdwan-transport-rules"
  network = data.google_compute_subnetwork.transport.network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "830", "443"]
  }

  allow {
    protocol = "udp"
    ports    = ["12346-13156"]
  }

  source_ranges = var.acl_cidr_blocks

}

resource "google_compute_firewall" "service" {
  name    = "sdwan-service-allow-all"
  network = data.google_compute_subnetwork.service.network

  allow {
    protocol = "all"
  }

  source_ranges = var.acl_cidr_blocks
}
