variable "location" {
    type = string
    description = "Azure location of terraform server environment"
    default = "westus2"
}

variable "tenantid" {
    type = string
    description = "ID of the Azure AD Tenant that will contain identities"
}

variable "data_storagetype" { 
    type = string
    description = "Disk type"
    default = "StandardSSD_LRS"
}

variable "vm_sku_2cpu" {
    type = string
    description = "SKU to use for 2 vCPU servers"
}

variable "vm_sku_2cpuv4" {
    type = string
    description = "SKU to use for 2 vCPU servers using v4 CPUs"
}

variable "vm_sku_4cpu" {
    type = string
    description = "SKU to use for 4 vCPU servers"
}

variable "vm_sku_4cpuv4" {
    type = string
    description = "SKU to use for 2 vCPU servers using v4 CPUs"
}

variable "sharedinfra_vnet_name" {
    type = string
    description = "Name of existing shared infrastructure VNet"
}

variable "sharedinfra_vnet_rg" {
    type = string
    description = "Resource Group of existing shared infrastructure VNet"
}

variable "epic_vnet_name" {
    type = string
    description = "Name of Epic VNet"
}

variable "epic_vnet_rg" {
    type = string
    description = "Resource Group of existing Epic VNet"
}

variable "dmz_vnet_name" {
    type = string
    description = "Name of DMZ VNet"
}

variable "dmz_vnet_rg" {
    type = string
    description = "Resource Group of existing DMZ VNet"
}

variable "epic_vnet_ipspace" {
    type = list
    description = "IP Space of Epic VNet"
}

variable "dmz_vnet_ipspace" {
    type = list
    description = "IP Space of DMZ VNet"
}

variable "wss_subnet" {
    type = list
    description = "IP Space of Web & Service Server subnet"
}

variable "odb_subnet" {
    type = list
    description = "IP Space of ODB subnet"
}

variable "appgw_subnet" {
    type = list
    description = "IP Space of Application Gateway subnet (must be /26)"
}

variable "fw_subnet" {
    type = list
    description = "IP Space of Azure Firewall subnet (must be /26)"
}

variable "azurebastion_subnet" {
    type = list
    description = "IP Space of Azure Bastion subnet (must be /26)"
}

variable "epic_mgmt_subnet" {
    type = list
    description = "IP Space of Epic Management subnet"
}

variable "netscaler_subnet" {
    type = list
    description = "IP Space of Citrix Netscaler subnet"
}

variable "dmzfirewall_name" {
    type = string
    description = "DNS prefix for the DMZ Firewall"
}

variable "vm_count" {
	type = map
	description = "The number of servers to build of each type"
	default = {
			"clarcon" = 0
			"hsw" = 0
			"icfg" = 0
			"kpr" = 0
			"sp" = 0
            "sql" = 0
	}
}

variable "ns_mgmt_ip_address" {
    type = string
    description = "Private static IP address"
}

variable "ns_front_ip_address" {
    type = string
    description = "Private static IP address"
}

variable "ns_back_ip_address" {
    type = string
    description = "Private static IP address"
}

variable "ns_epicappname" {
    type = string
    description = "Netscaler application name"
}

variable "clarcon_ip_address" {
    type = list
    description = "Private static IP address"
}

variable "clarcon_epicappname" {
    type = string
    description = "Clarity Console application name"
}

variable "hsw_ip_address" {
    type = list
    description = "Private static IP address"
}

variable "hsw_epicappname" {
    type = string
    description = "HSW application name"
}

variable "icfg_ip_address" {
    type = list
    description = "Private static IP address"
}

variable "icfg_epicappname" {
    type = string
    description = "IC foreground Epic application name"
}

variable "kpr_ip_address" {
    type = list
    description = "Private static IP address"
}

variable "kpr_epicappname" {
    type = string
    description = "Kuiper Epic application name"
}

variable "sp_ip_address" {
    type = list
    description = "Private static IP address"
}

variable "sp_epicappname" {
    type = string
    description = "System Pulse Epic application name"
}

variable "sql_ip_address" {
    type = list
    description = "Private static IP address"
}

variable "sql_epicappname" {
    type = string
    description = "SQL Epic application name"
}

variable "sql_datapath" {
	type = string
	description = "SQL Server default data path"
}

variable "sql_logpath" {
	type = string
	description = "SQL Server default log path"
}

variable "sql_temppath" {
	type = string
	description = "SQL Server default temp path"
}

variable "epic_storagename" {
	type = string
	description = "Name of the storage account that will be used to host installs and other files. All lowercase, only alphanumeric"
}

variable "shutdown" {
    type = bool
    description = "Should the VM auto shutdown"
}

variable "timezone" {
    type = string
    description = "OS Timezone"
    default = "Pacific Standard Time"
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

variable "sql_username" {
    type = string
    description = "Administrator username for SQL server"
	sensitive = true
}

variable "sql_password" {
    type = string
    description = "Administrator password for SQL server"
	sensitive = true
}