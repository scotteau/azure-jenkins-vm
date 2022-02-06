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
