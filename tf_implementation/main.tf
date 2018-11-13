# Storage account in SubB
# Network and VMs in SubA
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${var.resource_group_name-A}"
  }
  byte_length = 2
}
module "resource_group_A" {
  source = "./modules/az-resource_groups-A"
  resource_group_name = "${var.resource_group_name-A}"
  location = "${var.location}"
  owner = "88c61f3b-2a7a-4cb7-b219-c1cc4d64f301"
}
module "resource_group_B" {
  source = "./modules/az-resource_groups-B"
  resource_group_name = "${var.resource_group_name-B}"
  location = "${var.location}"
  owner = "88c61f3b-2a7a-4cb7-b219-c1cc4d64f301"
}

# Not using the storage module because this is the special one...
resource "azurerm_storage_account" "storage_account" {
  provider = "azurerm.subscriptionB"
  name = "azrcls${random_id.randomId.hex}"
  resource_group_name = "${module.resource_group_B.name}"
  location = "${var.location}"
  account_tier = "Standard"
  account_replication_type = "LRS"

  network_rules {
    virtual_network_subnet_ids = ["${module.network.private}"]
    # Interestingly, you have to have the IP of local host in the Storage Account
    # or you can't do the share creation
    ip_rules = ["72.49.64.78"]
  }
}
variable "share_name" {
  type = "string"
  default = "myshare"
}
resource "azurerm_storage_share" "testshare" {
  provider = "azurerm.subscriptionB"
  name = "${var.share_name}"
  resource_group_name  = "${azurerm_storage_account.storage_account.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.storage_account.name}"

  quota = 50
}

# VNet
module "network" {
  resource_group_name = "${module.resource_group_A.name}"
  name = "${var.resource_group_name-A}-vnet"
  location = "${var.location}"
  source = "./modules/az-network-A"
}

# # Add in the fun stuff for SubscriptionA...
# # # Public subnet VM
module "virtual_machine_public" {
  source = "./modules/az-virtual_machine_ubuntu-A"
  location = "${var.location}"
  resource_group_name = "${module.resource_group_A.name}"
  vm_name_prefix = "publicvm-01"
  subnet_id = "${module.network.public}"
  storage_account_name = "sharedvhds"
  share_name = "${azurerm_storage_share.testshare.name}"
  username = "${var.username}"
  storageAcctName = "${azurerm_storage_account.storage_account.name}"
  saKey = "${azurerm_storage_account.storage_account.primary_access_key}"
}
module "virtual_machine_private" {
  source = "./modules/az-virtual_machine_ubuntu-A"
  location = "${var.location}"
  resource_group_name = "${module.resource_group_A.name}"
  vm_name_prefix = "privatevm-01"
  subnet_id = "${module.network.private}"
  storage_account_name = "sharedvhds"
  share_name = "${azurerm_storage_share.testshare.name}"
  username = "${var.username}"
  storageAcctName = "${azurerm_storage_account.storage_account.name}"
  saKey = "${azurerm_storage_account.storage_account.primary_access_key}"
}
