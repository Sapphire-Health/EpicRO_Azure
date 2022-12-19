variable "servername1" {
    type = string
    description = "Server name for Netscaler 1"
}

variable "servername2" {
    type = string
    description = "Server name for Netscaler 2"
}

variable "location" {
    type = string
    description = "Azure location of terraform server environment"
    default = "westus2"
}

variable "rgname" {
    type = string
    description = "Resource group name"
}

variable "mgmt_subnet_id" {
    type = string
    description = "ID of the NSIP subnet"
}

variable "mgmt_ip_address1" {
    type = string
    description = "Private IP address of the NSIP (Management IP address)"
}

variable "mgmt_ip_address2" {
    type = string
    description = "Private IP address of the NSIP (Management IP address)"
}

variable "front_subnet_id" {
    type = string
    description = "ID of the frontend subnet"
}

variable "front_ip_address1" {
    type = string
    description = "Private IP address of the NIC for the frontend (VIP) subnet"
}

variable "front_ip_address2" {
    type = string
    description = "Private IP address of the NIC for the frontend (VIP) subnet"
}

variable "back_subnet_id" {
    type = string
    description = "ID of the backend subnet"
}

variable "back_ip_address1" {
    type = string
    description = "Private IP address of the NIC for the backend (SNIP) subnet"
}

variable "back_ip_address2" {
    type = string
    description = "Private IP address of the NIC for the backend (SNIP) subnet"
}

variable "appname" {
    type = string
    description = "Which application will be installed"
}

variable "vm_size" {
    type = string
    description = "Size of VM"
    default = "Standard_D2_v5"
}

variable "admin_username" {
    type = string
    description = "Administrator username for server"
	sensitive = true
}

variable "admin_password" {
    type = string
    description = "Administrator password for server"
	sensitive = true
}