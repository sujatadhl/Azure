resource "azurerm_network_interface" "network_interface" {
    name = "${var.name}-nic-public"
    location = azurerm_resource_group.sujata_rg.location
    resource_group_name = azurerm_resource_group.sujata_rg.name
    ip_configuration {
      name = "public"
      subnet_id = azurerm_subnet.sujata_subnet.id
      private_ip_address_allocation = "Dynamic"
    } 
}
resource "azurerm_network_interface_security_group_association" "nic_security-group_association" {
  network_interface_id = azurerm_network_interface.network_interface.id
  network_security_group_id = azurerm_network_security_group.sujata_nsg.id
}


#windows vm
resource "azurerm_windows_virtual_machine" "windows_vm" {
    name                = "${var.name}-vm"
    resource_group_name = azurerm_resource_group.sujata_rg.name
    location            = azurerm_resource_group.sujata_rg.location
    size                = "Standard_F2"
    admin_username      = "adminuser"
    admin_password      = "Test#111"
    network_interface_ids = [azurerm_network_interface.network_interface.id]

    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "MicrosoftWindowsServer"
      offer = "WindowsServer"
      sku = "2019-Datacenter"
      version = "latest"
    }
}