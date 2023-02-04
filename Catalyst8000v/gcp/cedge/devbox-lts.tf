resource "google_compute_instance" "devbox-cedge" {
  name         = "devbox-cedge-multicloud"
  machine_type = "e2-small"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    subnetwork = var.subnet_service
    network_ip = cidrhost(data.google_compute_subnetwork.service.ip_cidr_range, 17)
    # Ephemeral public IP
    access_config {
    }
  }

  metadata = {
    user-data = <<-EOF
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
  }
}
