output "endpoint" {
    value = "${azurerm_storage_account.storage_account.primary_blob_endpoint}"
}

output "primary_key" {
    value = "${azurerm_storage_account.storage_account.primary_access_key}"
}