#resource_group
resource "azurerm_resource_group" "sujata_rg" {
    name                = "${var.name}-rg"
    location            = var.location
}

#nsg
resource "azurerm_network_security_group" "sujata_nsg" {
    name                = "${var.name}-nsg"
    location            = azurerm_resource_group.sujata_rg.location
    resource_group_name = azurerm_resource_group.sujata_rg.name
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

#public_ip
resource "azurerm_public_ip" "public_ip" {
    count = 2
    name                = "${var.name}-public-ip-${count.index + 1}"
    resource_group_name = azurerm_resource_group.sujata_rg.name
    location            = azurerm_resource_group.sujata_rg.location
    allocation_method   = "Static"
    sku = "Standard"
}   

#nat
resource "azurerm_nat_gateway" "sujata_nat" {
    name                = "${var.name}-nat"
    location            = azurerm_resource_group.sujata_rg.location
    resource_group_name = azurerm_resource_group.sujata_rg.name
}

#nat_gateway_public_ip_association
resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_public_ip_association" {
    nat_gateway_id = azurerm_nat_gateway.sujata_nat.id
    public_ip_address_id = azurerm_public_ip.public_ip[0].id
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
    count               = length(var.public_subnet)
    name                = "public-subnet-${count.index + 1}"
    address_prefixes    = [var.public_subnet[count.index]]
    resource_group_name = azurerm_resource_group.sujata_rg.name
    virtual_network_name= azurerm_virtual_network.sujata_vnet.name
}

#private_subnet
resource "azurerm_subnet" "sujata_private_subnet" {
    count               = length(var.private_subnet)
    name                = "private-subnet-${count.index + 1}"
    address_prefixes    = [var.private_subnet[count.index]]
    resource_group_name = azurerm_resource_group.sujata_rg.name
    virtual_network_name= azurerm_virtual_network.sujata_vnet.name
    
}

#attaching nat to private subnet
resource "azurerm_subnet_nat_gateway_association" "sujata_nat_association" {
    count              = length(var.private_subnet)
    subnet_id           = element(azurerm_subnet.sujata_private_subnet[*].id, count.index)
    nat_gateway_id      = azurerm_nat_gateway.sujata_nat.id
}

resource "azurerm_subnet_network_security_group_association" "sujata_nsg_association_public" {
    count              = length(var.public_subnet)
    subnet_id           = element(azurerm_subnet.sujata_public_subnet[*].id, count.index)
    network_security_group_id = azurerm_network_security_group.sujata_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "sujata_nsg_association_private" {
    count              = length(var.private_subnet)
    subnet_id           = element(azurerm_subnet.sujata_private_subnet[*].id, count.index)
    network_security_group_id = azurerm_network_security_group.sujata_nsg.id
}

# resource "azurerm_route_table" "sujata_public_rt" {
#     name                = "${var.name}-public-rt"
#     location            = azurerm_resource_group.sujata_rg.location
#     resource_group_name = azurerm_resource_group.sujata_rg.name  
#     route {
#         name    = "public_route"
#         address_prefix = "0.0.0.0/0"
#         next_hop_type = "Internet"
#     }     
# }

# resource "azurerm_route_table" "sujata_private_rt" {
#     name                = "${var.name}-private-rt"
#     location            = azurerm_resource_group.sujata_rg.location
#     resource_group_name = azurerm_resource_group.sujata_rg.name 
#     #    route {
#     #     name    = "private_route"
#     #     address_prefix = ""
#     #     next_hop_type = ""
#     # }       
# }

# resource "azurerm_subnet_route_table_association" "public_rt_association" {
#     count               = length(var.public_subnet)
#     subnet_id           = element(azurerm_subnet.sujata_public_subnet[*].id, count.index)
#     route_table_id      = azurerm_route_table.sujata_public_rt.id  
# }

# resource "azurerm_subnet_route_table_association" "private_rt_association" {
#     count               = length(var.private_subnet)
#     subnet_id           = element(azurerm_subnet.sujata_private_subnet[*].id, count.index)
#     route_table_id      = azurerm_route_table.sujata_private_rt.id  
# }
