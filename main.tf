

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = {
    project = var.jenkins
  }
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    project = var.jenkins
  }
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "public-ip" {
  name                = var.public_ip_name
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = {
    project = var.jenkins
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "sg" {
  name                = var.network_security_group_name
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  #  security_rule {
  #    name                       = "HTTP_80_Open"
  #    priority                   = 1002
  #    direction                  = "Inbound"
  #    access                     = "Allow"
  #    protocol                   = "Tcp"
  #    source_port_range          = "*"
  #    destination_port_range     = "80"
  #    source_address_prefix      = "*"
  #    destination_address_prefix = "*"
  #  }
  #
  #  security_rule {
  #    name                       = "HTTPS_443_Open"
  #    priority                   = 1003
  #    direction                  = "Inbound"
  #    access                     = "Allow"
  #    protocol                   = "Tcp"
  #    source_port_range          = "*"
  #    destination_port_range     = "443"
  #    source_address_prefix      = "*"
  #    destination_address_prefix = "*"
  #  }


  security_rule {
    name                       = "Jenkins_8080"
    priority                   = 2000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    project = var.jenkins
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = var.network_interface_name
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "NicConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip.id
  }

  tags = {
    project = var.jenkins
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

## Generate random text for a unique storage account name
#resource "random_id" "randomId" {
#  keepers = {
#    # Generate a new ID only when a new resource group is defined
#    resource_group = azurerm_resource_group.rg.name
#  }
#
#  byte_length = 8
#}


## Create storage account for boot diagnostics
#resource "azurerm_storage_account" "storage_account" {
#  name                     = "diag${random_id.randomId.hex}"
#  resource_group_name      = azurerm_resource_group.rg.name
#  location                 = var.resource_group_location
#  account_tier             = "Standard"
#  account_replication_type = "LRS"
#
#  tags = {
#    project = var.jenkins
#  }
#}


resource "tls_private_key" "linux_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "local_file" "jenkins_azure" {
  filename = "${path.cwd}/credentials/jenkins_azure_key.pem"
  content  = tls_private_key.linux_vm_key.private_key_pem
}


# Create virtual machine
resource "azurerm_linux_virtual_machine" "linux-vm" {
  name                  = var.linux_virtual_machine_name
  location              = var.resource_group_location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "ubuntu"
  admin_username                  = var.user_name
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.user_name
    public_key = tls_private_key.linux_vm_key.public_key_openssh
  }

  custom_data = filebase64("./scripts/custom_data.sh")

  #  boot_diagnostics {
  #    storage_account_uri = azurerm_storage_account.storage_account.primary_blob_endpoint
  #  }

  depends_on = [
    azurerm_network_interface.nic,
    tls_private_key.linux_vm_key
  ]

  tags = {
    project = var.jenkins
  }

  provisioner "local-exec" {
    command = "chmod 400 $SSH_KEY && touch $(pwd)/scripts/ssh.sh && echo \"ssh -i $SSH_KEY $USERNAME@$VM_IP\" > $(pwd)/scripts/ssh.sh && chmod +x $(pwd)/scripts/ssh.sh"

    environment = {
      SSH_KEY  = local_file.jenkins_azure.filename
      VM_IP    = azurerm_linux_virtual_machine.linux-vm.public_ip_address
      USERNAME = azurerm_linux_virtual_machine.linux-vm.admin_username
    }
  }
}
