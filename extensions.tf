resource "azurerm_virtual_machine_extension" "backend_setup" {
  count                = var.enable_vm_extensions ? 1 : 0
  name                 = "setup-backend-iis-node"
  virtual_machine_id   = azurerm_windows_virtual_machine.back.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    commandToExecute = "powershell.exe -ExecutionPolicy Bypass -File setup-backend.ps1 -BackendZipUrl '${var.backend_zip_url}' -DbServer '${azurerm_network_interface.data.private_ip_address}' -DbUser '${var.sql_admin_username}' -DbPassword '${var.sql_admin_password}' -JwtSecret '${var.jwt_secret}'"
  })

  settings = jsonencode({
    fileUris = ["https://raw.githubusercontent.com/ErickMedeiros/fifa2026-azure-terraform/main/scripts/setup-backend.ps1"]
  })

  depends_on = [azurerm_windows_virtual_machine.data]
}

resource "azurerm_virtual_machine_extension" "frontend_setup" {
  count                = var.enable_vm_extensions ? 1 : 0
  name                 = "setup-frontend-iis-arr"
  virtual_machine_id   = azurerm_windows_virtual_machine.front.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    commandToExecute = "powershell.exe -ExecutionPolicy Bypass -File setup-frontend.ps1 -FrontendZipUrl '${var.frontend_zip_url}' -BackendUrl 'http://${azurerm_network_interface.back.private_ip_address}'"
  })

  settings = jsonencode({
    fileUris = ["https://raw.githubusercontent.com/ErickMedeiros/fifa2026-azure-terraform/main/scripts/setup-frontend.ps1"]
  })

  depends_on = [azurerm_virtual_machine_extension.backend_setup]
}

resource "azurerm_virtual_machine_extension" "sql_prepare" {
  count                = var.enable_vm_extensions ? 1 : 0
  name                 = "prepare-sql-bacpac"
  virtual_machine_id   = azurerm_windows_virtual_machine.data.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  protected_settings = jsonencode({
    commandToExecute = "powershell.exe -ExecutionPolicy Bypass -File setup-sql.ps1 -BacpacUrl '${var.bacpac_url}'"
  })

  settings = jsonencode({
    fileUris = ["https://raw.githubusercontent.com/ErickMedeiros/fifa2026-azure-terraform/main/scripts/setup-sql.ps1"]
  })

  depends_on = [azurerm_windows_virtual_machine.data]
}
