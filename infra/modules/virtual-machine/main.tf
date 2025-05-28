resource "azurerm_public_ip" "main" {
  name                = "pip-${var.workload}-${var.server_name_affix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-${var.workload}-${var.server_name_affix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "default"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "vm-${var.workload}-${var.server_name_affix}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.main.id]

  custom_data = filebase64("${path.module}/scripts/${var.custom_data_script}")

  bypass_platform_safety_checks_on_user_schedule_enabled = true
  patch_mode                                             = "AutomaticByPlatform"

  // Required by the Monitor agent
  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.public_key_path)
  }

  os_disk {
    name                 = "osdisk-${var.workload}-${var.server_name_affix}"
    caching              = "ReadOnly"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  lifecycle {
    ignore_changes = [
      custom_data
    ]
  }
}

resource "azurerm_managed_disk" "data_disk" {
  name                 = "disk-${var.workload}-${var.server_name_affix}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "20"
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  lun                = "10"
  caching            = "ReadOnly"
}
