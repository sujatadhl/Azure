resource "azurerm_mysql_flexible_server" "webapp_db_server" {
  name                   = "${var.name}-db-server"
  resource_group_name    = azurerm_resource_group.sujata_rg.name
  location               = azurerm_resource_group.sujata_rg.location
  administrator_login    = var.admin_username
  administrator_password = var.admin_password
  delegated_subnet_id    = azurerm_subnet.sujata_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.webapp_dns.id
  zone = "1"
  sku_name               = "GP_Standard_D2ds_v4"
  depends_on             = [azurerm_private_dns_zone_virtual_network_link.webapp_dns_link]
}
resource "azurerm_mysql_flexible_database" "webapp_db" {
  name                = "todo"
  server_name         = azurerm_mysql_flexible_server.webapp_db_server.name
  resource_group_name = azurerm_resource_group.sujata_rg.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}
resource "azurerm_private_dns_zone" "webapp_dns" {
  name                = "${var.name}.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.sujata_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "webapp_dns_link" {
  name                  = "webappLink.com"
  private_dns_zone_name = azurerm_private_dns_zone.webapp_dns.name
  virtual_network_id    = azurerm_virtual_network.sujata_vnet.id
  resource_group_name   = azurerm_resource_group.sujata_rg.name
}
