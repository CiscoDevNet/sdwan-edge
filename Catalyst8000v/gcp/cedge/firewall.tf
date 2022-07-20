resource "google_compute_firewall" "transport" {
  name    = "transport-firewall"
  network = data.google_compute_subnetwork.transport.network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    direction = "INGRESS"
    ports    = ["22", "830", "443"]
  }

  allow {
    protocol = "udp"
    direction = "INGRESS"
    ports    = ["12346-13156"]
  }

  allow {
    protocol = "all"
    direction = "EGRESS"
  }

  source_ranges = ["0.0.0.0/0"]

}

resource "google_compute_firewall" "service" {
  name    = "service-firewall"
  network = data.google_compute_subnetwork.service.network

  allow {
    protocol = "all"
    direction = "INGRESS"
  }

  allow {
    protocol = "all"
    direction = "EGRESS"
  }

  source_ranges = ["0.0.0.0/0"]
}
