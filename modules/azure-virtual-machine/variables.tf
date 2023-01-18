variable "servername" {
    type = string
    description = "Server name"
}

variable "location" {
    type = string
    description = "Azure location of terraform server environment"
    default = "eastus2"
}

variable "rgname" {
    type = string
    description = "Resource group name"
}

variable "subnet_id" {
    type = string
    description = "ID of the subnet"
}

variable "ip_address" {
    type = string
    description = "Private IP address"
}

variable "epicappname" {
    type = string
    description = "Which Epic application will be installed"
}

variable "vm_size" {
    type = string
    description = "Size of VM"
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

variable "timezone" {
    type = string
    description = "OS Timezone"
    default = "Pacific Standard Time"
}

variable "enable_autoupdate" {
    type = string
    description = "true or false to enable automatic updates"
}

variable "patch_mode" {
    type = string
    description = "Set Patch Mode to either 'Manual' or 'AutomaticByOS'"
}

variable "shutdown" {
    type = bool
    description = "Should the VM auto shutdown"
}

variable "kuiperip" {
    type = string
    description = "IP of Kuiper server for WinRM Firewall rule"
}

variable "accountname" {
    type = string
    description = "Name of the Storage Account containing post deploy script"
}

variable "accountkey" {
    type = string
    description = "Access Key to Storage Account containing post deploy script"
}
