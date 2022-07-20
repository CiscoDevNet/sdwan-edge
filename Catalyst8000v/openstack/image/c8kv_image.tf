resource "openstack_images_image_v2" "cedge" {
  name             = "c8kv2"
#  local_file_path  = "qcow/c8000v-universalk9_16G_serial.17.08.01a.qcow2"
  image_source_url = "http://1.2.3.4/public/images/qcow/cedge/c8000v-universalk9_16G_serial.17.08.01a.qcow2"
  web_download     = true 
  container_format = "bare"
  disk_format      = "qcow2"
  
}