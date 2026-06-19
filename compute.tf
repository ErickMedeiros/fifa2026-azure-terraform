resource "azurerm_public_ip" "front" {
  name                = "pip-${local.vm_front_name}"
  location            = var.location_app
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "back" {
  name                = "pip-${local.vm_back_name}"
  location            = var.location_app
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "data" {
  name                = "pip-${local.vm_data_name}"
  location            = var.location_data
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "front" {
  name                = "nic-${local.vm_front_name}"
  location            = var.location_app
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.front.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.front.id
  }
}

resource "azurerm_network_interface" "back" {
  name                = "nic-${local.vm_back_name}"
  location            = var.location_app
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.back.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.back.id
  }
}

resource "azurerm_network_interface" "data" {
  name                = "nic-${local.vm_data_name}"
  location            = var.location_data
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.data.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.data.id
  }
}

resource "azurerm_windows_virtual_machine" "front" {
  name                = local.vm_front_name
  computer_name       = "vm-fend-cin-001"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location_app
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.front.id]
  tags                = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 127
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  provision_vm_agent = true
}

resource "azurerm_windows_virtual_machine" "back" {
  name                = local.vm_back_name
  computer_name       = "vm-bend-cin-001"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location_app
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.back.id]
  tags                = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 127
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  provision_vm_agent = true
}

resource "azurerm_marketplace_agreement" "sql2022" {
  publisher = "MicrosoftSQLServer"
  offer     = "SQL2022-WS2022"
  plan      = "SQLDEV-GEN2"
}

resource "azurerm_windows_virtual_machine" "data" {
  name                = local.vm_data_name
  computer_name       = "vm-data-aes-001"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location_data
  size                = var.vm_size
  admin_username      = var.sql_admin_username
  admin_password      = var.sql_admin_password
  network_interface_ids = [azurerm_network_interface.data.id]
  tags                = var.tags

  depends_on = [azurerm_marketplace_agreement.sql2022]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 127
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2022-WS2022"
    sku       = "SQLDEV-GEN2"
    version   = "latest"
  }

  provision_vm_agent = true
}

