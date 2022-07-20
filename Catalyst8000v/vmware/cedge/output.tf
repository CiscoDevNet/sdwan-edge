output "cedge_id" {
  value = vsphere_virtual_machine.cedge.id
}

output "cedge_transport_ip" {
    value = vsphere_virtual_machine.cedge.guest_ip_addresses.0
}

output "cedge_service_ip" {
    value = vsphere_virtual_machine.cedge.guest_ip_addresses.1
}
