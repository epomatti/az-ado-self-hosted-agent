terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

resource "random_string" "affix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

locals {
  workload = "contoso${random_string.affix.result}"

  # Virtual machines
  app_admin   = "appuser"
  agent_admin = "agentuser"
}

### Group ###
resource "azurerm_resource_group" "default" {
  name     = "rg-${var.workload}"
  location = var.location
}

### Network ###
module "vnet" {
  source              = "./modules/virtual-network"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

### Container Registry ###
module "cr" {
  source              = "./modules/container-registry"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled
}

### Virtual Machines ###
module "vm_agent" {
  source              = "./modules/virtual-machine"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  workload            = var.workload
  public_key_path     = var.vm_public_key_path
  admin_username      = var.vm_admin_username
  size                = var.vm_size
  subnet_id           = module.vnet.default_subnet_id
  server_name_affix   = "agent"
  custom_data_script  = "ubuntu.sh"

  image_publisher = var.vm_image_publisher
  image_offer     = var.vm_image_offer
  image_sku       = var.vm_image_sku
  image_version   = var.vm_image_version
}

module "vm_app" {
  source              = "./modules/virtual-machine"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  workload            = var.workload
  public_key_path     = var.vm_public_key_path
  admin_username      = var.vm_admin_username
  size                = var.vm_size
  subnet_id           = module.vnet.default_subnet_id
  server_name_affix   = "app"
  custom_data_script  = "ubuntu.sh"

  image_publisher = var.vm_image_publisher
  image_offer     = var.vm_image_offer
  image_sku       = var.vm_image_sku
  image_version   = var.vm_image_version
}

### Private Link ###
module "private_link" {
  source                      = "./modules/private-link"
  workload                    = local.workload
  resource_group_name         = azurerm_resource_group.default.name
  location                    = azurerm_resource_group.default.location
  vnet_id                     = module.vnet.vnet_id
  container_registry_id       = module.cr.id
  private_endpoints_subnet_id = module.vnet.default_subnet_id
}
