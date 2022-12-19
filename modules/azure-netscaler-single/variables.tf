variable "servername" {
    type = string
    description = "Server name for Netscaler 1"
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

variable "subnet_id" {
    type = string
    description = "ID of the subnet"
}

variable "mgmt_ip_address" {
    type = string
    description = "Private IP address of the NSIP (Management IP address)"
}

variable "back_ip_address" {
    type = string
    description = "Private IP address of the NIC for the backend (SNIP) subnet"
}

variable "front_ip_address" {
    type = string
    description = "Private IP address of the NIC for the frontend (VIP) subnet"
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

variable "aset_id" {
    type = string
    description = "Availability Set ID"
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