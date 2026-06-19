resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location_app
  tags     = var.tags
}

resource "azurerm_virtual_network" "app" {
  name                = local.vnet_app_name
  address_space       = local.address_space_app
  location            = var.location_app
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_virtual_network" "data" {
  name                = local.vnet_data_name
  address_space       = local.address_space_data
  location            = var.location_data
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_subnet" "front" {
  name                 = local.subnet_front_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = local.subnet_front_prefix
}

resource "azurerm_subnet" "back" {
  name                 = local.subnet_back_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = local.subnet_back_prefix
}

resource "azurerm_subnet" "data" {
  name                 = local.subnet_data_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.data.name
  address_prefixes     = local.subnet_data_prefix
}

resource "azurerm_virtual_network_peering" "app_to_data" {
  name                      = "peer-${local.vnet_app_name}-to-${local.vnet_data_name}"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.app.name
  remote_virtual_network_id = azurerm_virtual_network.data.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "data_to_app" {
  name                      = "peer-${local.vnet_data_name}-to-${local.vnet_app_name}"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.data.name
  remote_virtual_network_id = azurerm_virtual_network.app.id
  allow_forwarded_traffic   = true
}

