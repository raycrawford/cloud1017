module "storage" {
  source = "../az-storage-A"
  name = "${var.storage_account_name}"
  location = "eastus2"
  resource_group_name = "${var.resource_group_name}"
  containers = ["other", "vhds"]
}
resource "azurerm_public_ip" "main" {
  provider = "azurerm.subscriptionA"
  name                         = "${var.vm_name_prefix}-pip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  domain_name_label            = "${var.vm_name_prefix}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30

  tags {
    environment = "test"
  }
}
resource "azurerm_network_interface" "main" {
  provider = "azurerm.subscriptionA"
  name                = "${var.vm_name_prefix}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "ip-config-main"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.main.id}"
  }
}
resource "azurerm_virtual_machine" "main" {
  provider = "azurerm.subscriptionA"
  name                  = "${var.vm_name_prefix}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_DS2_v2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "18.04.201807240"
  }

  storage_os_disk {
    name              = "${var.vm_name_prefix}-osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.vm_name_prefix}"
    admin_username = "${var.username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = "${file("~/.ssh/id_rsa.pub")}"
      path = "/home/${var.username}/.ssh/authorized_keys"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "echo $(hostname)",
      "echo 'Accessing file share test'",
      "sudo mkdir /mnt/MyAzureFileShare",
      "cmd_output=$(sudo mount --types cifs //${var.storageAcctName}.file.core.windows.net/${var.share_name} /mnt/MyAzureFileShare --options vers=3.0,username=${var.storageAcctName},password=${var.saKey},dir_mode=0777,file_mode=0777,serverino 2>&1)",
      "echo $(hostname)",
      "echo $cmd_output",
      "if [[ $cmd_output == *\"mount error\"* ]]",
      "then",
      "echo 'Mount Failed'",
      "else",
      "echo 'Mount succeeded'",
      "fi",
    ]
    connection {
      type     = "ssh"
      user     = "${var.username}"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }  
  tags {
    idle = "true"
  }
}

# There is a bug with the following code.  It keeps throwing a:
## Error: Error refreshing state: 1 error(s) occurred:
## * module.virtual_machine_private.data.azurerm_public_ip.main: 1 error(s) occurred:
## * module.virtual_machine_private.data.azurerm_public_ip.main: data.azurerm_public_ip.main: Error: Public IP "privatevm-01-pip" (Resource Group "cloud1017a") was not found
# I need to make up a simple demo to debug and submit it...

# data "azurerm_public_ip" "main" {
#   provider = "azurerm.subscriptionA"
#   name                = "${azurerm_public_ip.main.name}"
#   resource_group_name = "${var.resource_group_name}"
# }
