resource "azurerm_resource_group" "resource_group" {
  provider = "azurerm.subscriptionB"
  name = "${var.resource_group_name}"
  location = "${var.location}"
}
resource "azurerm_role_assignment" "authZ" {
  provider = "azurerm.subscriptionB"
  scope              = "${azurerm_resource_group.resource_group.name}"
  role_definition_name = "Contributor"
  principal_id       = "${var.owner}"
  scope = "${azurerm_resource_group.resource_group.id}"
}
