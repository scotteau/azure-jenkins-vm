# vm_public_ip
output "vm_public_ip" {
  value = azurerm_linux_virtual_machine.linux-vm.public_ip_address
}

# vm_id
output "vm_id" {
  value = azurerm_linux_virtual_machine.linux-vm.virtual_machine_id
}

output "ssh_key_file_location" {
  value = local_file.jenkins_azure.filename
}
