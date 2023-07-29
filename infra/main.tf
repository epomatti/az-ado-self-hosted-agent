terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  backend "local" {
    path = ".workspace/terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  app_admin   = "appuser"
  agent_admin = "agentuser"
}

### Group ###
resource "azurerm_resource_group" "default" {
  name     = "rg-${var.workload}"
  location = var.location
}

### Network ###
resource "azurerm_virtual_network" "default" {
  name                = "vnet-${var.workload}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_subnet" "default" {
  name                 = "subnet-default"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.0.0/24"]
}

### ACR ###

resource "azurerm_container_registry" "acr" {
  name                = "acr${var.workload}888888"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku                 = "Basic"
  admin_enabled       = true
}

### VM Application ###
module "vm_app" {
  source         = "./modules/vm"
  location       = azurerm_resource_group.default.location
  group          = azurerm_resource_group.default.name
  affix          = "${var.workload}-app"
  admin_username = local.app_admin
  vm_size        = var.vm_size
  custom_data    = filebase64("${path.module}/cloud-init/app.sh")
  subnet         = azurerm_subnet.default.id
}

### VM Agent ###
module "vm_agent" {
  source         = "./modules/vm"
  location       = azurerm_resource_group.default.location
  group          = azurerm_resource_group.default.name
  affix          = "${var.workload}-agent"
  admin_username = local.agent_admin
  vm_size        = var.vm_size
  custom_data    = filebase64("${path.module}/cloud-init/agent.sh")
  subnet         = azurerm_subnet.default.id
}
