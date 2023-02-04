resource "azurerm_public_ip" "devbox" {
  name                = "devbox-${var.name}-pip"
  location            = data.azurerm_resource_group.rg_c8000v.location
  resource_group_name = data.azurerm_resource_group.rg_c8000v.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "devbox" {
  name                = "devbox-${var.name}-nic"
  location            = data.azurerm_resource_group.rg_c8000v.location
  resource_group_name = data.azurerm_resource_group.rg_c8000v.name

  ip_configuration {
    name                          = "devbox-${var.name}-nic"
    subnet_id                     = data.azurerm_subnet.service_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(data.azurerm_subnet.service_subnet.address_prefixes[0], 17)
    public_ip_address_id          = azurerm_public_ip.devbox.id
  }
}

resource "azurerm_linux_virtual_machine" "devbox" {
  name                            = "devbox-${var.name}"
  location                        = data.azurerm_resource_group.rg_c8000v.location
  resource_group_name             = data.azurerm_resource_group.rg_c8000v.name
  size                            = "Standard_B1ms"
  admin_username                  = var.account_username
  admin_password                  = var.account_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.devbox.id,
  ]
  custom_data                     = base64encode(<<EOF
#cloud-config
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
  )

  admin_ssh_key {
    username = var.account_username
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3+do2TD2CcHpqiYkP2dRfSdWlxkeQtTjIK9YdtTEWq36MDvT893TiJww7R45kcMncikpgTj8FddKa+/Y3AzuyXHHeCSIzJNBApa/jSVgQ6JOO/liqqI2koglY1gasJqGHsdXFaoqs+67lc0QtlmuojKFpDjwWq2/UKC2Z4IFORk1pUVORw+voDdWhHGtfhoMIBv7CXABMyTdop1z2KkXxCc2m0MRmtypwNnF8NpxhTIsP3tF6d59cRcVmLBETp1KZYQ6dOdoFHxNRidOTRtD5FV10RzsHzS3Rx7ONUeQBNnsxRyRpLyozcrCpr+JyiOijJvKthcLQFnDj/20SiyQb"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"

    # diff_disk_settings {
    #   option = "Local"
    # }
  }
}
