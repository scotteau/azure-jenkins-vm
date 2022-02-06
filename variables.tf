variable "jenkins" {
  default = "Jenkins"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "resource_group_location" {
  type        = string
  description = "Resource group location"
}

variable "virtual_network_name" {
  type        = string
  description = "Virtual network name"
}

variable "subnet_name" {
  type        = string
  description = "Subnet name"
}

variable "public_ip_name" {
  type        = string
  description = "public IP name"
}

variable "network_security_group_name" {
  type        = string
  description = "Network security group name"
}

variable "network_interface_name" {
  type        = string
  description = "Network interface name"
}

variable "linux_virtual_machine_name" {
  type        = string
  description = "Name of the linux VM"
}

variable "user_name" {
  type        = string
  description = "user name"
}

variable "inbound_security_rules" {
  default = [
    {
      destination_port_range = 22,
      priority               = 1001,
      name                   = "SSH"
    },
    {
      destination_port_range = 8080,
      priority               = 2000,
      name                   = "Jenkins"
    }
    #    {
    #      destination_port_range = 80,
    #      priority = 1002,
    #      name = "http"
    #    },
    #    {
    #      destination_port_range = 443,
    #      priority = 1003,
    #      name = "https"
    #    }
  ]
}
