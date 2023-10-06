resource "google_compute_instance" "cedge" {
  name           = var.name
  machine_type   = var.instance_type
  zone           = var.zone
  can_ip_forward = true

  boot_disk {
    initialize_params {
      image = var.image_id
    }
  }

  network_interface {
    subnetwork = var.subnet_transport
    access_config {
    }
  }
  network_interface {
    subnetwork = var.subnet_service
  }

  metadata = {
    startup-script = file("cloud-init/ciscosdwan_cloud_init.${var.name}.cfg")
  }

  labels = var.common_tags
}
