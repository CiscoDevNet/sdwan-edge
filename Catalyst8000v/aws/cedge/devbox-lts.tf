data "aws_ami" "ubuntu-focal" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "devbox-cedge" {
  ami                         = "${data.aws_ami.ubuntu-focal.id}"
  instance_type               = "t2.small"
  vpc_security_group_ids      = ["${aws_security_group.transport.id}", "${aws_security_group.mosh.id}"]
  subnet_id                   = "${data.aws_subnet.subnet_transport.id}"
  private_ip                  = cidrhost(data.aws_subnet.subnet_transport.cidr_block, 17)
  associate_public_ip_address = true
  user_data                   = <<EOF
#cloud-config
ssh_pwauth: yes
hostname: devbox-${var.name}
users:
- name: cisco
  gecos: Cisco user
  shell: /bin/bash
  groups: [adm, users, crontab, kvm, tcpdump, _ssh, admin, netdev]
  # teccld-2000
  passwd: $6$rounds=4096$9aeGpcwNyf4$HZKW4yTmYDOPdnWNqNVLpalxnRlJOYiQJb/RK.8I15F9vUHLhfdhRSRJAO4nA7rYQH3whQe2RcET/jEEQBRMe.
  lock_passwd: False
  ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3+do2TD2CcHpqiYkP2dRfSdWlxkeQtTjIK9YdtTEWq36MDvT893TiJww7R45kcMncikpgTj8FddKa+/Y3AzuyXHHeCSIzJNBApa/jSVgQ6JOO/liqqI2koglY1gasJqGHsdXFaoqs+67lc0QtlmuojKFpDjwWq2/UKC2Z4IFORk1pUVORw+voDdWhHGtfhoMIBv7CXABMyTdop1z2KkXxCc2m0MRmtypwNnF8NpxhTIsP3tF6d59cRcVmLBETp1KZYQ6dOdoFHxNRidOTRtD5FV10RzsHzS3Rx7ONUeQBNnsxRyRpLyozcrCpr+JyiOijJvKthcLQFnDj/20SiyQb
  sudo: ALL=(ALL) NOPASSWD:ALL
packages:
- net-tools
- kitty-terminfo
- mosh
- tmux
runcmd:
- chown -R cisco:cisco /home/cisco
- curl -Os https://downloads.thousandeyes.com/agent/install_thousandeyes.sh
- chmod +x install_thousandeyes.sh
- ./install_thousandeyes.sh -b ${var.teagent_account_token}
- ip address add 10.128.5.17/24 dev eth1
- ip link set dev eth1 up
- ip route add 10.128.0.0/16 via 10.128.5.11 dev eth1
- ip route add 22.0.0.0/8 via 10.128.5.11 dev eth1
write_files:
- path: /home/cisco/.bash_history
  permissions: '0600'
  content: |
    ip -br a
    ip r
- path: /home/cisco/.tmux.conf
  permissions: '0644'
  content: |
    set-option -g prefix C-a
    new-session
EOF

  tags = {
    Name = "devbox-${var.name}"
  }
}

resource "aws_network_interface" "devbox-cedge" {
  subnet_id                   = "${data.aws_subnet.subnet_service.id}"
  security_groups             = ["${aws_security_group.service.id}"]
  private_ips                 = [cidrhost(data.aws_subnet.subnet_service.cidr_block, 17)]

  attachment {
    instance     = "${aws_instance.devbox-cedge.id}"
    device_index = 1
  }
}

resource "aws_security_group" "mosh" {
  name        = "allow_mosh"
  description = "Allow Mobile Shell inbound traffic"
  vpc_id      = data.aws_vpc.instance.id

  ingress {
    from_port   = 60000  # allow mosh
    to_port     = 61000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_mosh"
  }
}

resource "aws_route53_record" "devbox-cedge" {
  count   = var.route53_zone == "" ? 0 : 1
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = "devbox-${var.name}.${data.aws_route53_zone.selected[0].name}"
  type    = "A"
  ttl     = "300"
  records = [ "${aws_instance.devbox-cedge.public_ip}" ]
}

output "devbox_cedge_public_ip" {
  value = aws_instance.devbox-cedge.public_ip
}
