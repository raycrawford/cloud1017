output "public_subnet" {
    value = "${module.network.public}"
}
output "private_subnet" {
    value = "${module.network.private}"
}