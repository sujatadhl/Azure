resource "azurerm_network_interface" "network_interface" {
  name                = "${var.name}-nic"
  location            = azurerm_resource_group.sujata_rg.location
  resource_group_name = azurerm_resource_group.sujata_rg.name
  ip_configuration {
    name                          = "public"
    subnet_id                     = azurerm_subnet.sujata_public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}
resource "azurerm_network_interface_security_group_association" "nic_security-group_association" {
  network_interface_id      = azurerm_network_interface.network_interface.id
  network_security_group_id = azurerm_network_security_group.sujata_nsg.id
}

#windows vm
resource "azurerm_windows_virtual_machine" "windows_vm" {
  name                  = "${var.name}-vm"
  resource_group_name   = azurerm_resource_group.sujata_rg.name
  location              = azurerm_resource_group.sujata_rg.location
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  admin_password        = "Test#111"
  network_interface_ids = [azurerm_network_interface.network_interface.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
#vm backup
resource "azurerm_recovery_services_vault" "webapp_recovery_vault" {
  name = "${var.name}-recovery-vault"
  location = azurerm_resource_group.sujata_rg.location
  resource_group_name = azurerm_resource_group.sujata_rg.name
  sku = "Standard"
}

resource "azurerm_backup_policy_vm" "backup_policy" {
  name = "${var.name}-backup-policy"
  resource_group_name = azurerm_resource_group.sujata_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.webapp_recovery_vault.name
  backup {
    frequency = "Daily"
    time = "23:00"
    }
  retention_daily {
    count = 7
  }
}

resource "azurerm_backup_protected_vm" "backup_vm" {
  resource_group_name = azurerm_resource_group.sujata_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.webapp_recovery_vault.name
  source_vm_id = azurerm_windows_virtual_machine.windows_vm.id
  backup_policy_id = azurerm_backup_policy_vm.backup_policy.id
}