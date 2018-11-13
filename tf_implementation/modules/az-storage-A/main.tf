resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${var.resource_group_name}"
  }
  byte_length = 2
}
resource "azurerm_storage_account" "storage_account" {
  provider = "azurerm.subscriptionA"
  name = "azrcls${var.name}${random_id.randomId.hex}"
  resource_group_name = "${var.resource_group_name}"
  location = "${var.location}"
  account_tier = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_storage_container" "storage_container" {
  provider = "azurerm.subscriptionA"
  count = "${length(var.containers)}"
  name = "${var.containers[count.index]}"
  resource_group_name = "${var.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.storage_account.name}"
  container_access_type = "private"  
}
