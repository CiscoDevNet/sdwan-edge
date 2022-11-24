# Create NICs

resource "aws_network_interface" "transport" {
  subnet_id         = data.aws_subnet.subnet_transport.id
  private_ips       = [cidrhost(data.aws_subnet.subnet_transport.cidr_block, 11)]
  security_groups 	= [aws_security_group.transport.id]
  source_dest_check = false
  description 			= "transport (vpn 0)"

  tags = {
    Name = "${var.name}_interface_transport" 
  }
}

resource "aws_network_interface" "service" {
  subnet_id       	= data.aws_subnet.subnet_service.id
  private_ips       = [cidrhost(data.aws_subnet.subnet_service.cidr_block, 11)]
  security_groups 	= [aws_security_group.service.id]
  source_dest_check = false
  description 			= "service (vpn 1)"
  tags = {
    Name = "${var.name}_interface_service" 
  }
}

# Create SD-WAN Router
resource "aws_instance" "cedge" {
  ami                         = var.image_id
  instance_type               = var.instance_type
  availability_zone           = data.aws_subnet.subnet_transport.availability_zone
  user_data                   = file("cloud-init/ciscosdwan_cloud_init.${var.name}.cfg")
  user_data_replace_on_change = true
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.transport.id
  }

  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.service.id
  }

  tags = {
    Name = var.name 
  }

}


# Allocate and assign public IP address
resource "aws_eip" "cedge_eip" {
  vpc                       = true
  network_interface         = aws_network_interface.transport.id
  associate_with_private_ip = tolist(aws_network_interface.transport.private_ips)[0]
  depends_on 		    	      = [aws_instance.cedge]
  tags = {
    Name = "${var.name}_eip" 
  }
}
