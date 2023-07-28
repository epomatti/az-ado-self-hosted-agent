resource "azurerm_public_ip" "main" {
  name                = "pip-${var.affix}"
  location            = var.location
  resource_group_name = var.group
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-${var.affix}"
  location            = var.location
  resource_group_name = var.group

  ip_configuration {
    name                          = "default"
    subnet_id                     = var.subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "vm-${var.affix}"
  location              = var.location
  resource_group_name   = var.group
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = "P@ssw0rd.123"
  network_interface_ids = [azurerm_network_interface.main.id]

  custom_data = var.custom_data

  // Required by the Monitor agent
  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    name                 = "osdisk-${var.affix}"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [
      custom_data
    ]
  }
}
