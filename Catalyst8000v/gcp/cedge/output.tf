output "cedge_id" {
  value = google_compute_instance.cedge.id
}

output "cedge_transport_ip" {
    value = google_compute_instance.cedge.network_interface.0.network_ip
}

output "cedge_service_ip" {
    value = google_compute_instance.cedge.network_interface.1.network_ip
}

output "cedge_transport_public_ip" {
    value = google_compute_instance.cedge.network_interface.0.access_config.0.nat_ip
}
