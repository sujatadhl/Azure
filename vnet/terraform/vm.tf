resource "azurerm_network_interface" "public_network_interface" {
    name = "${var.name}-nic-public"
    location = azurerm_resource_group.sujata_rg.location
    resource_group_name = azurerm_resource_group.sujata_rg.name
    ip_configuration {
      name = "public"
      subnet_id = azurerm_subnet.sujata_public_subnet[0].id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.public_ip[1].id
    } 
}

resource "azurerm_network_interface_security_group_association" "nic_security-group_association" {
  network_interface_id = azurerm_network_interface.private_network_interface.id
  network_security_group_id = azurerm_network_security_group.sujata_nsg.id
}

resource "azurerm_network_interface" "private_network_interface" {
    name = "${var.name}-nic-private"
    location = azurerm_resource_group.sujata_rg.location
    resource_group_name = azurerm_resource_group.sujata_rg.name
    ip_configuration {
      name = "private"
      subnet_id = azurerm_subnet.sujata_public_subnet[0].id
      private_ip_address_allocation = "Dynamic"
    } 
}

resource "azurerm_linux_virtual_machine" "linux_vm_public" {
    name    = "${var.name}-vm-public"
    resource_group_name = azurerm_resource_group.sujata_rg.name
    location = azurerm_resource_group.sujata_rg.location
    size = "Standard_D2s_v3"
    admin_username = "adminuser"
    admin_password = "Test#1"
    disable_password_authentication = false
    network_interface_ids = [azurerm_network_interface.public_network_interface.id]
    

    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-jammy"
      sku = "22_04-lts-gen2"
      version = "latest"
    }
}

resource "azurerm_linux_virtual_machine" "linux_vm_private" {
    name    = "${var.name}-vm-private"
    resource_group_name = azurerm_resource_group.sujata_rg.name
    location = azurerm_resource_group.sujata_rg.location
    size = "Standard_D2s_v3"
    admin_username = "adminuser"
    admin_password = "Test#1"
    disable_password_authentication = false
    network_interface_ids = [azurerm_network_interface.private_network_interface.id]

    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer = "0001-com-ubuntu-server-jammy"
      sku = "22_04-lts-gen2"
      version = "latest"
    }
 
}