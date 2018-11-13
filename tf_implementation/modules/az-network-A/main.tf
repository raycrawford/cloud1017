resource "azurerm_network_security_group" "nsg" {
  provider = "azurerm.subscriptionA"
  name                = "${var.name}-${var.location}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "ssh_inbound" {
  provider = "azurerm.subscriptionA"
  name                        = "ssh_inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}
resource "azurerm_network_security_rule" "rdp_inbound" {
  provider = "azurerm.subscriptionA"
  name                        = "rdp_inbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}
resource "azurerm_virtual_network" "network" {
  provider = "azurerm.subscriptionA"
  name                = "${var.name}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  dns_servers         = ["10.0.0.4", "10.0.0.5", "8.8.8.8", "8.8.4.4"]
}
resource "azurerm_subnet" "private" {
  provider = "azurerm.subscriptionA"
  name           = "Private"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "10.0.1.0/24"
  service_endpoints = ["Microsoft.Storage"]
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}
resource "azurerm_subnet_network_security_group_association" "private" {
  provider = "azurerm.subscriptionA"
  subnet_id                 = "${azurerm_subnet.private.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}
resource "azurerm_subnet" "public" {
  provider = "azurerm.subscriptionA"
  name           = "Public"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "10.0.0.0/24"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}
resource "azurerm_subnet_network_security_group_association" "public" {
  provider = "azurerm.subscriptionA"
  subnet_id                 = "${azurerm_subnet.public.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}


