output "vnet" {
  value = "${azurerm_virtual_network.network.id}"
}
output "public" {
  value = "${azurerm_subnet.public.id}"
}
output "private" {
  value = "${azurerm_subnet.private.id}"
}
