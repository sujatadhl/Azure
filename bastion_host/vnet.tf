#resource_group
resource "azurerm_resource_group" "sujata_rg" {
    name                = "${var.name}-rg"
    location            = var.location
}

#public_ip
resource "azurerm_public_ip" "public_ip" {
    name                = "${var.name}-public-ip"
    resource_group_name = azurerm_resource_group.sujata_rg.name
    location            = azurerm_resource_group.sujata_rg.location
    allocation_method   = "Static"
    sku = "Standard"
}   

#nsg
resource "azurerm_network_security_group" "sujata_nsg" {
    name                = "${var.name}-nsg"
    location            = azurerm_resource_group.sujata_rg.location
    resource_group_name = azurerm_resource_group.sujata_rg.name
    security_rule {
        name                       = "RDP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}
#vnet
resource "azurerm_virtual_network" "sujata_vnet" {   
    name                = "${var.name}-vnet"
    address_space       = var.cidr_block
    location            = azurerm_resource_group.sujata_rg.location
    resource_group_name = azurerm_resource_group.sujata_rg.name
}

#public_subnet
resource "azurerm_subnet" "sujata_subnet" {
    name                = "${var.name}-subnet"
    address_prefixes    = var.public_subnet
    resource_group_name = azurerm_resource_group.sujata_rg.name
    virtual_network_name= azurerm_virtual_network.sujata_vnet.name
}

#bastion host
resource "azurerm_bastion_host" "bastion_host" {
    name = "${var.name}-bastion-host"
    location = azurerm_resource_group.sujata_rg.location
    resource_group_name = azurerm_resource_group.sujata_rg.name
    ip_configuration {
      name = "configuration"
      subnet_id = azurerm_subnet.bastion_subnet.id
      public_ip_address_id = azurerm_public_ip.public_ip.id
    }
}

#bastion subnet
resource "azurerm_subnet" "bastion_subnet" {
    name                = "AzureBastionSubnet"
    address_prefixes    = var.bastion_subnet
    resource_group_name = azurerm_resource_group.sujata_rg.name
    virtual_network_name= azurerm_virtual_network.sujata_vnet.name
}
