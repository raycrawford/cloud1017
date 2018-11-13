# Purpose
Satisfy [CLOUD-1017](https://jira.kroger.com/jira/browse/CLOUD-1017).  The objective was to explore how Azure Service Endpoints could be used and show that they work cross subscription in line with the current architectural direction.

# Findings
## Service Endpoints
Service Endpoints do work cross-subscription.  This was shown using a Storage Account file share connected to 2 VMs, one which could access the file share mount and one which can not.

When implemented, the output announces whether or not the mount was successful.  Examples were done in both Terraform and the Azure CLI.

## Virtual Machines
Virtual machines can not span Subscriptions.  Attaching a NIC from one subscription to a VNet in another subscription did not work.  Neither did associating a VM in one subscription with a NIC in another.

Net, the VNet and the VM need to be in the same subscription at this point in time.  This will drive VNet, peering and VPN design.

## Noteworthy
* When doing a Service Endpoint in Terraform, the IP address of the host executing the Terraform must be included in the Service Endpoint if anything beyond blob storage is desired.  As in the example here, if the IP of the Terraform host isn't included in the main.tf, the File Share create will fail.
* An issue was identified and opened with the Azure TF team concerning the documentation.  The azurerm_virtual_network and azurerm_subnet show that the subnet can reference the virtual network name, but this is not the case.  To work, it must reference the VNet with an implicit dependency as shown in the example.
