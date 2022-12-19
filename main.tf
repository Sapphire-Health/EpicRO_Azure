## Configure the Microsoft Azure Provider
## <https://www.terraform.io/docs/providers/azurerm/index.html>
terraform {
  backend "local"  {

  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.34.0"
    }
  }
}

provider "azurerm" {
  features {}
  
}

###############Get existing data sources###############
data "azurerm_virtual_network" "sharedinfra_vnet" {
  name                = var.sharedinfra_vnet_name
  resource_group_name = var.sharedinfra_vnet_rg
}

###############Create new VNets###############
## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network>

resource "azurerm_virtual_network" "epic_vnet" {
  name                = var.epic_vnet_name
  address_space       = var.epic_vnet_ipspace
  location            = var.location
  resource_group_name = var.epic_vnet_rg
  tags = {
	Terraform = "Yes"
  }  
}

resource "azurerm_virtual_network" "dmz_vnet" {
  name                = var.dmz_vnet_name
  address_space       = var.dmz_vnet_ipspace
  location            = var.location
  resource_group_name = var.dmz_vnet_rg
  tags = {
	Terraform = "Yes"
  }  
}



###############Create Resource Groups##################
resource "azurerm_resource_group" "rg_mgmt" {
  name     = "USW2-EpicRO-EpicMgmt-RG"
  location = var.location
  tags = {
	Terraform = "Yes"
  }
}

resource "azurerm_resource_group" "rg_netscaler" {
  name     = "USW2-EpicRO-NetScaler-RG"
  location = var.location
  tags = {
	Terraform = "Yes"
  }
}

resource "azurerm_resource_group" "rg_wss" {
  name     = "USW2-EpicRO-WSS-RG"
  location = var.location
  tags = {
	Terraform = "Yes"
  }  
}

resource "azurerm_resource_group" "rg_odb" {
  name     = "USW2-EpicRO-ODB-RG"
  location = var.location
  tags = {
	Terraform = "Yes"
  }  
}

#resource "azurerm_resource_group" "rg_appgw" {
#  name     = "USW2-EpicRO-APPGW-RG"
#  location = var.location
#  tags = {
#	Terraform = "Yes"
#  }  
#}

###############Create shared VNET resources###############

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet> 
resource "azurerm_subnet" "epic_mgmt_subnet" {
  name                 = "USW2-EpicRO-SharedInfra-EpicMgmt"
  resource_group_name  = data.azurerm_virtual_network.sharedinfra_vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.sharedinfra_vnet.name
  address_prefixes     = var.epic_mgmt_subnet
  service_endpoints    = ["Microsoft.Sql","Microsoft.Storage"]
  private_endpoint_network_policies_enabled = "true"
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet> 
resource "azurerm_subnet" "netscaler_subnet" {
  name                 = "USW2-EpicRO-SharedInfra-Netscaler"
  resource_group_name  = data.azurerm_virtual_network.sharedinfra_vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.sharedinfra_vnet.name
  address_prefixes     = var.netscaler_subnet
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet> 
#resource "azurerm_subnet" "azureappgw_subnet" {
#  name                 = "ApplicationGatewaySubnet"
#  resource_group_name  = azurerm_virtual_network.dmz_vnet.resource_group_name
#  virtual_network_name = azurerm_virtual_network.dmz_vnet.name
#  service_endpoints    = ["Microsoft.KeyVault"]  
#  address_prefixes     = var.appgw_subnet  
#}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet> 
resource "azurerm_subnet" "azurefw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_virtual_network.dmz_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.dmz_vnet.name
  address_prefixes     = var.fw_subnet  
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet> 
resource "azurerm_subnet" "azurebastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_virtual_network.dmz_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.dmz_vnet.name
  address_prefixes     = var.azurebastion_subnet  
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet> 
resource "azurerm_subnet" "wss_subnet" {
  name                 = "USW2-EpicRO-Epic-WSS"
  resource_group_name  = azurerm_virtual_network.epic_vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.epic_vnet.name
  address_prefixes     = var.wss_subnet
  service_endpoints    = ["Microsoft.Sql","Microsoft.Storage"]
  private_endpoint_network_policies_enabled = "true"
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group>
resource "azurerm_network_security_group" "epic_mgmt_nsg" {
  name                 = "SharedInfra-EpicMgmt-NSG"
  location             = azurerm_resource_group.rg_mgmt.location
  resource_group_name  = azurerm_resource_group.rg_mgmt.name
  
  security_rule {
    name                       = "HTTPS_Bastion_Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.azurebastion_subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS_WSS_Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.wss_subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS_ODB_Inbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.odb_subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS_MGMT_Inbound"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.epic_mgmt_subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WinRM_Inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985-5986"
    source_address_prefixes    = var.kpr_ip_address
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ICMP_Inbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                         = "ETL_Inbound"
    priority                     = 400
    direction                    = "Inbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "10000"
    source_address_prefixes      = var.odb_subnet
    destination_address_prefixes = var.clarcon_ip_address
  }

  security_rule {
    name                       = "RDP_Inbound"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.azurebastion_subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SQL_ODBC_Kuiper_Inbound"
    priority                   = 600
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefixes    = var.kpr_ip_address
    destination_address_prefixes = var.sql_ip_address
  }

  security_rule {
    name                       = "SQL_ODBC_SystemPulse_Inbound"
    priority                   = 610
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefixes    = var.sp_ip_address
    destination_address_prefixes = var.sql_ip_address
  }

  security_rule {
    name                       = "SQL_ODBC_Clarcon_Inbound"
    priority                   = 620
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefixes    = var.clarcon_ip_address
    destination_address_prefixes = var.sql_ip_address
  }

  security_rule {
    name                       = "DenyAll"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }  

  tags = {
	Terraform = "Yes"
  }    
}

resource "azurerm_network_security_group" "netscaler_nsg" {
  name                 = "SharedInfra-Netscaler-NSG"
  location             = azurerm_resource_group.rg_netscaler.location
  resource_group_name  = azurerm_resource_group.rg_netscaler.name

  security_rule {
    name                       = "HTTPS_Kuiper_Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.kpr_ip_address
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS_FW_Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.fw_subnet
    destination_address_prefix = "*"
  }  

  security_rule {
    name                       = "HTTP_FW_Inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = var.fw_subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Netscaler_to_Netscaler_Inbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = var.netscaler_subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ICMP_Inbound"
    priority                   = 400
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAll"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }  

  tags = {
	Terraform = "Yes"
  }    
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group>
resource "azurerm_network_security_group" "wss_nsg" {
  name                 = "Epic-WSS-NSG"
  location             = azurerm_resource_group.rg_wss.location
  resource_group_name  = azurerm_resource_group.rg_wss.name
  
  security_rule {
    name                       = "HTTPS_Netscaler_Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WinRM_Kuiper_Inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["135","5985-5986"]
    source_address_prefixes    = var.kpr_ip_address
    destination_address_prefix = "*"
  }    

  security_rule {
    name                       = "ICMP_Inbound"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDP_Inbound"
    priority                   = 500
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.azurebastion_subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAll"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  } 

  tags = {
	Terraform = "Yes"
  }    
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association>
resource "azurerm_subnet_network_security_group_association" "epicmgmt_nsg_attach" {
  subnet_id                 = azurerm_subnet.epic_mgmt_subnet.id
  network_security_group_id = azurerm_network_security_group.epic_mgmt_nsg.id
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association>
resource "azurerm_subnet_network_security_group_association" "netscaler_nsg_attach" {
  subnet_id                 = azurerm_subnet.netscaler_subnet.id
  network_security_group_id = azurerm_network_security_group.netscaler_nsg.id
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association>
resource "azurerm_subnet_network_security_group_association" "wss_nsg_attach" {
  subnet_id                 = azurerm_subnet.wss_subnet.id
  network_security_group_id = azurerm_network_security_group.wss_nsg.id
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering>
resource "azurerm_virtual_network_peering" "dmz_to_sharedinfra_peer" {
  name                      = "Peer-${var.dmz_vnet_name}-to-${var.sharedinfra_vnet_name}"
  resource_group_name       = var.dmz_vnet_rg
  virtual_network_name      = azurerm_virtual_network.dmz_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.sharedinfra_vnet.id
}

resource "azurerm_virtual_network_peering" "sharedinfra_to_dmz_peer" {
  name                      = "Peer-${var.sharedinfra_vnet_name}-to-${var.dmz_vnet_name}"
  resource_group_name       = var.sharedinfra_vnet_rg
  virtual_network_name      = data.azurerm_virtual_network.sharedinfra_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.dmz_vnet.id
}

resource "azurerm_virtual_network_peering" "dmz_to_epic_peer" {
  name                      = "Peer-${var.dmz_vnet_name}-to-${var.epic_vnet_name}"
  resource_group_name       = var.dmz_vnet_rg
  virtual_network_name      = azurerm_virtual_network.dmz_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.epic_vnet.id
}

resource "azurerm_virtual_network_peering" "epic_to_dmz_peer" {
  name                      = "Peer-${var.epic_vnet_name}-to-${var.dmz_vnet_name}"
  resource_group_name       = var.epic_vnet_rg
  virtual_network_name      = azurerm_virtual_network.epic_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.dmz_vnet.id
}

resource "azurerm_virtual_network_peering" "sharedinfra_to_epic_peer" {
  name                      = "Peer-${var.sharedinfra_vnet_name}-to-${var.epic_vnet_name}"
  resource_group_name       = var.sharedinfra_vnet_rg
  virtual_network_name      = data.azurerm_virtual_network.sharedinfra_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.epic_vnet.id
}

resource "azurerm_virtual_network_peering" "epic_to_sharedinfra_peer" {
  name                      = "Peer-${var.epic_vnet_name}-to-${var.sharedinfra_vnet_name}"
  resource_group_name       = var.epic_vnet_rg
  virtual_network_name      = azurerm_virtual_network.epic_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.sharedinfra_vnet.id
}

##<https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip>
resource "azurerm_public_ip" "bastionip" {
  name                = "RO-EPICBASTION-PIP"
  location            = azurerm_resource_group.rg_mgmt.location
  resource_group_name = azurerm_resource_group.rg_mgmt.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
	Terraform = "Yes"
  }  
}

##<https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host>
resource "azurerm_bastion_host" "bastion" {
  name                = "RO-EPICBASTION"
  location            = azurerm_resource_group.rg_mgmt.location
  resource_group_name = azurerm_resource_group.rg_mgmt.name
  sku                 = "Basic"
  ip_configuration {
    name                 = "RO-EPICBASTION-IPCONFIG"
    subnet_id            = azurerm_subnet.azurebastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastionip.id
  }
  tags = {
	Terraform = "Yes"
  }
}

#################Netscaler###########
#resource "azurerm_availability_set" "ns_aset" {
#  name                = "${var.ns_epicappname}_ASET"
#  location            = azurerm_resource_group.rg_mgmt.location
#  resource_group_name = azurerm_resource_group.rg_mgmt.name
#  
#  tags = {
#    Application = var.ns_epicappname
#	  Terraform = "Yes"
#  }
#}
#module "netscaler" {
#  source             = "./modules/azure-netscaler-single"
#  servername         = "RO-${var.ns_epicappname}-1"
#  location           = azurerm_resource_group.rg_mgmt.location
#  rgname             = azurerm_resource_group.rg_mgmt.name
#  subnet_id          = azurerm_subnet.netscaler_subnet.id
#  mgmt_ip_address    = var.ns_mgmt_ip_address
#  back_ip_address    = var.ns_back_ip_address
#  front_ip_address   = var.ns_front_ip_address
#  appname            = var.ns_epicappname
#  vm_size            = var.vm_sku_4cpu
#  aset_id            = azurerm_availability_set.ns_aset.id  
#  admin_username     = "${var.admin_username}${var.ns_epicappname}"	
#  admin_password     = "${var.admin_password}${var.ns_epicappname}" 
#}

################HSW###############
resource "azurerm_availability_set" "hsw_aset" {
  name                = "${var.hsw_epicappname}_ASET"
  location            = azurerm_resource_group.rg_wss.location
  resource_group_name = azurerm_resource_group.rg_wss.name
  
  tags = {
    EpicApp = var.hsw_epicappname
	Terraform = "Yes"
  }
}
module "hsw_vms" {
  count              = var.vm_count["hsw"]

  source             = "./modules/azure-virtual-machine"
  servername         = "RO-${var.hsw_epicappname}-${count.index+1}"
  location           = azurerm_resource_group.rg_wss.location
  rgname             = azurerm_resource_group.rg_wss.name
  subnet_id          = azurerm_subnet.wss_subnet.id
  ip_address         = var.hsw_ip_address[count.index]
  epicappname        = var.hsw_epicappname
  vm_size            = var.vm_sku_4cpu
  aset_id            = azurerm_availability_set.hsw_aset.id
  admin_username     = "${var.admin_username}${var.hsw_epicappname}${count.index+1}"	
  admin_password     = "${var.admin_password}${var.hsw_epicappname}${count.index+1}"
  enable_autoupdate  = "true"
  patch_mode         = "AutomaticByOS"  
  shutdown           = var.shutdown
  timezone           = var.timezone  
  kuiperip           = var.kpr_ip_address[0]  
}

################Interconnect Foreground###############
resource "azurerm_availability_set" "icfg_aset" {
  name                = "${var.icfg_epicappname}_ASET"
  location            = azurerm_resource_group.rg_wss.location
  resource_group_name = azurerm_resource_group.rg_wss.name
  
  tags = {
    EpicApp = var.icfg_epicappname
	Terraform = "Yes"
  }
}
module "icfg_vms" {
  count              = var.vm_count["icfg"]

  source             = "./modules/azure-virtual-machine"
  servername         = "RO-${var.icfg_epicappname}-${count.index+1}"
  location           = azurerm_resource_group.rg_wss.location
  rgname             = azurerm_resource_group.rg_wss.name
  subnet_id          = azurerm_subnet.wss_subnet.id
  ip_address         = var.icfg_ip_address[count.index]
  epicappname        = var.icfg_epicappname
  vm_size            = var.vm_sku_2cpu
  aset_id            = azurerm_availability_set.icfg_aset.id
  admin_username     = "${var.admin_username}${var.icfg_epicappname}${count.index+1}"	
  admin_password     = "${var.admin_password}${var.icfg_epicappname}${count.index+1}"
  enable_autoupdate  = "true"
  patch_mode         = "AutomaticByOS"  
  shutdown           = var.shutdown
  timezone           = var.timezone  
  kuiperip           = var.kpr_ip_address[0]  
}

###############Kuiper###############
resource "azurerm_availability_set" "kpr_aset" {
  name                = "${var.kpr_epicappname}_ASET"
  location            = azurerm_resource_group.rg_mgmt.location
  resource_group_name = azurerm_resource_group.rg_mgmt.name
  
  tags = {
    EpicApp = var.kpr_epicappname
	Terraform = "Yes"
  }
}
module "kpr_vms" {
  count              = var.vm_count["kpr"]

  source             = "./modules/azure-virtual-machine"
  servername         = "RO-${var.kpr_epicappname}-${count.index+1}"
  location           = azurerm_resource_group.rg_mgmt.location
  rgname             = azurerm_resource_group.rg_mgmt.name
  subnet_id          = azurerm_subnet.epic_mgmt_subnet.id
  ip_address         = var.kpr_ip_address[count.index]
  epicappname        = var.kpr_epicappname
  vm_size            = var.vm_sku_4cpu
  aset_id            = azurerm_availability_set.kpr_aset.id
  admin_username     = "${var.admin_username}${var.kpr_epicappname}${count.index+1}"	
  admin_password     = "${var.admin_password}${var.kpr_epicappname}${count.index+1}"
  enable_autoupdate  = "true"
  patch_mode         = "AutomaticByOS"  

  shutdown           = var.shutdown
  timezone           = var.timezone  
  kuiperip           = var.kpr_ip_address[0]
}

################System Pulse###############
resource "azurerm_availability_set" "sp_aset" {
  name                = "${var.sp_epicappname}_ASET"
  location            = azurerm_resource_group.rg_mgmt.location
  resource_group_name = azurerm_resource_group.rg_mgmt.name
  
  tags = {
    EpicApp = var.sp_epicappname
	Terraform = "Yes"
  }
}
module "sp_vms" {
  count              = var.vm_count["sp"]

  source             = "./modules/azure-virtual-machine"
  servername         = "RO-${var.sp_epicappname}-${count.index+1}"
  location           = azurerm_resource_group.rg_mgmt.location
  rgname             = azurerm_resource_group.rg_mgmt.name
  subnet_id          = azurerm_subnet.epic_mgmt_subnet.id
  ip_address         = var.sp_ip_address[count.index]
  epicappname        = var.sp_epicappname
  vm_size            = var.vm_sku_4cpu
  aset_id            = azurerm_availability_set.sp_aset.id
  admin_username     = "${var.admin_username}${var.sp_epicappname}${count.index+1}"	
  admin_password     = "${var.admin_password}${var.sp_epicappname}${count.index+1}"
  enable_autoupdate  = "true"
  patch_mode         = "AutomaticByOS"  
  shutdown           = var.shutdown
  timezone           = var.timezone  
  kuiperip           = var.kpr_ip_address[0]
}

###############Clarity Console###############
resource "azurerm_availability_set" "clarcon_aset" {
  name                = "${var.clarcon_epicappname}_ASET"
  location            = azurerm_resource_group.rg_wss.location
  resource_group_name = azurerm_resource_group.rg_wss.name
  
  tags = {
    EpicApp = var.clarcon_epicappname
	Terraform = "Yes"
  }
}
module "clarcon_vms" {
  count              = var.vm_count["clarcon"]

  source             = "./modules/azure-virtual-machine-withdisk"
  servername         = "RO-${var.clarcon_epicappname}-${count.index+1}"
  location           = azurerm_resource_group.rg_wss.location
  rgname             = azurerm_resource_group.rg_wss.name
  subnet_id          = azurerm_subnet.wss_subnet.id
  ip_address         = var.clarcon_ip_address[count.index]
  epicappname        = var.clarcon_epicappname
  vm_size            = var.vm_sku_4cpu
  datadisk_size      = "128"
  aset_id            = azurerm_availability_set.clarcon_aset.id
  admin_username     = "${var.admin_username}${var.clarcon_epicappname}${count.index+1}"	
  admin_password     = "${var.admin_password}${var.clarcon_epicappname}${count.index+1}"
  enable_autoupdate  = "true"
  patch_mode         = "AutomaticByOS"  
  shutdown           = var.shutdown
  timezone           = var.timezone  
  kuiperip           = var.kpr_ip_address[0]
}

###############SQL###############

resource "azurerm_availability_set" "sql_aset" {
  name                = "${var.sql_epicappname}_ASET"
  location            = azurerm_resource_group.rg_mgmt.location
  resource_group_name = azurerm_resource_group.rg_mgmt.name
  
  tags = {
    EpicApp = var.sql_epicappname
    Terraform = "Yes"
  }
}
module "sql_vms" {
  count              = var.vm_count["sql"]

  source             = "./modules/azure-sql-virtual-machine"
  servername         = "RO-${var.sql_epicappname}-${count.index+1}"
  location           = azurerm_resource_group.rg_mgmt.location
  rgname             = azurerm_resource_group.rg_mgmt.name
  subnet_id          = azurerm_subnet.epic_mgmt_subnet.id
  ip_address         = var.sql_ip_address[count.index]
  epicappname        = var.sql_epicappname
  vm_size            = var.vm_sku_4cpu
  aset_id            = azurerm_availability_set.sql_aset.id
  admin_username     = "${var.admin_username}${var.sql_epicappname}${count.index+1}"	
  admin_password     = "${var.admin_password}${var.sql_epicappname}${count.index+1}"
  datadisk_size      = "128"
  logdisk_size       = "128"  
  sql_username       = var.sql_username
  sql_password       = var.sql_password
  sql_datapath       = var.sql_datapath
  sql_logpath        = var.sql_logpath
  enable_autoupdate  = "true"
  patch_mode         = "AutomaticByOS"  
  timezone           = var.timezone  
}

################Storage Account##################
## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account>
resource "azurerm_storage_account" "epicstorage" {
	name = "${lower(var.epic_storagename)}"
	resource_group_name = azurerm_resource_group.rg_mgmt.name
	location = azurerm_resource_group.rg_mgmt.location
	account_kind = "StorageV2"
	account_tier = "Standard"
	account_replication_type = "LRS"
	access_tier = "Hot"
	network_rules {
		default_action             = "Deny"
		virtual_network_subnet_ids = [azurerm_subnet.epic_mgmt_subnet.id,azurerm_subnet.wss_subnet.id]
  }
  tags = {
	  Terraform = "Yes"
  }  
}

##<https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint>
resource "azurerm_private_endpoint" "epicstorageendpoint" {
  name                = "${var.epic_storagename}-PEP"
  location            = azurerm_resource_group.rg_mgmt.location
  resource_group_name = azurerm_resource_group.rg_mgmt.name
  subnet_id           = azurerm_subnet.epic_mgmt_subnet.id
  private_service_connection {
    name                           = "${var.epic_storagename}-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.epicstorage.id
    is_manual_connection           = false
	  subresource_names              = ["file"]
  }
  tags = {
	  Terraform = "Yes"
  }
}

##############Application Gateway############
#resource "azurerm_user_assigned_identity" "appgw_id" {
#  name                = "EpicRO-AppGW-ManagedId"  
#  resource_group_name = azurerm_resource_group.rg_appgw.name
#  location            = azurerm_virtual_network.dmz_vnet.location
#  tags = {
#	  Terraform = "Yes"
#  }  
#}
#
#resource "azurerm_key_vault" "appgw_kv" {
#  name                = "EpicRO-AppGW-KeyVault"  
#  resource_group_name = azurerm_resource_group.rg_appgw.name
#  location            = azurerm_virtual_network.dmz_vnet.location
#  sku_name            = "standard"
#  tenant_id           = var.tenantid
#  access_policy {
#    tenant_id = var.tenantid
#    object_id = azurerm_user_assigned_identity.appgw_id.principal_id
#
#    certificate_permissions = [
#      "Get",
#    ]
#
#    secret_permissions = [
#      "Get",
#    ]    
#  }
#  network_acls {
#    bypass = "None"
#    default_action = "Deny"
#    virtual_network_subnet_ids = [azurerm_subnet.azureappgw_subnet.id]
#  }
#
#  tags = {
#	  Terraform = "Yes"
#  }  
#
#  depends_on = [
#    azurerm_user_assigned_identity.appgw_id
#  ]  
#}