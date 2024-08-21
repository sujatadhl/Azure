#resource_group
resource "azurerm_resource_group" "sujata_rg" {
  name     = "${var.name}-rg"
  location = var.location
}

#public_ip
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.name}-public-ip"
  resource_group_name = azurerm_resource_group.sujata_rg.name
  location            = azurerm_resource_group.sujata_rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
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
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Sql"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
    security_rule {
    name                       = "App"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "4000"
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
resource "azurerm_subnet" "sujata_public_subnet" {
  name                 = "${var.name}-public-subnet"
  address_prefixes     = var.public_subnet
  resource_group_name  = azurerm_resource_group.sujata_rg.name
  virtual_network_name = azurerm_virtual_network.sujata_vnet.name
}
#delegated_subnet
resource "azurerm_subnet" "sujata_subnet" {
  name                 = "${var.name}-subnet"
  address_prefixes     = var.delegated_subnet
  resource_group_name  = azurerm_resource_group.sujata_rg.name
  virtual_network_name = azurerm_virtual_network.sujata_vnet.name
  delegation {
    name = "webapp"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
