## Create an availability set
## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set>
resource "azurerm_availability_set" "aset" {
  name                = "${var.appname}_ASET"
  location            = var.location
  resource_group_name = var.rgname
  
  tags = {
    Application = var.appname
	Terraform = "Yes"
  }
}


## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface>
resource "azurerm_network_interface" "mgmtnic1" {
  name                = "${var.servername1}_mgmt_nic"
  location            = var.location
  resource_group_name = var.rgname
  enable_accelerated_networking = "true"    

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.mgmt_subnet_id
    private_ip_address_allocation = "Static"
	  private_ip_address            = var.mgmt_ip_address1
  }
  
  tags = {
    Application = var.appname
	  Terraform = "Yes"
  }
}

resource "azurerm_network_interface" "mgmtnic2" {
  name                = "${var.servername2}_mgmt_nic"
  location            = var.location
  resource_group_name = var.rgname
  enable_accelerated_networking = "true"    

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.mgmt_subnet_id
    private_ip_address_allocation = "Static"
	  private_ip_address            = var.mgmt_ip_address2
  }
  
  tags = {
    Application = var.appname
	  Terraform = "Yes"
  }
}

resource "azurerm_network_interface" "frontnic1" {
  name                = "${var.servername1}_front_nic"
  location            = var.location
  resource_group_name = var.rgname
  enable_accelerated_networking = "true"    

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.front_subnet_id
    private_ip_address_allocation = "Static"
	  private_ip_address            = var.front_ip_address1
  }
  
  tags = {
    Application = var.appname
	  Terraform = "Yes"
  }
}

resource "azurerm_network_interface" "frontnic2" {
  name                = "${var.servername2}_front_nic"
  location            = var.location
  resource_group_name = var.rgname
  enable_accelerated_networking = "true"    

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.front_subnet_id
    private_ip_address_allocation = "Static"
	  private_ip_address            = var.front_ip_address2
  }
  
  tags = {
    Application = var.appname
	  Terraform = "Yes"
  }
}


resource "azurerm_network_interface" "backnic1" {
  name                = "${var.servername1}_back_nic"
  location            = var.location
  resource_group_name = var.rgname
  enable_accelerated_networking = "true"    

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.back_subnet_id
    private_ip_address_allocation = "Static"
	  private_ip_address            = var.back_ip_address1
  }
  
  tags = {
    Application = var.appname
	  Terraform = "Yes"
  }
}

resource "azurerm_network_interface" "backnic2" {
  name                = "${var.servername2}_back_nic"
  location            = var.location
  resource_group_name = var.rgname
  enable_accelerated_networking = "true"  

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.back_subnet_id
    private_ip_address_allocation = "Static"
	  private_ip_address            = var.back_ip_address2
  }
  
  tags = {
    Application = var.appname
	  Terraform = "Yes"
  }
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine>
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = var.servername1
  resource_group_name = var.rgname
  location            = var.location
  size                = var.vm_size
  availability_set_id = azurerm_availability_set.aset.id  
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = "false"
  network_interface_ids = [
    azurerm_network_interface.mgmtnic1.id,
    azurerm_network_interface.frontnic1.id,
    azurerm_network_interface.backnic1.id 
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
	name                 = "${var.servername1}_OSdisk"	
  }

  source_image_reference {
    publisher = "citrix"
    offer     = "netscalervpx-131"
    sku       = "netscalerbyol"
    version   = "latest"
  }
  
  tags = {
    Application = var.appname
	Terraform = "Yes"
  }
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine>
resource "azurerm_linux_virtual_machine" "vm2" {
  name                = var.servername2
  resource_group_name = var.rgname
  location            = var.location
  size                = var.vm_size
  availability_set_id = azurerm_availability_set.aset.id    
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = "false"
  network_interface_ids = [
    azurerm_network_interface.mgmtnic2.id,
    azurerm_network_interface.frontnic2.id,
    azurerm_network_interface.backnic2.id 
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
	name                 = "${var.servername2}_OSdisk"	
  }

  source_image_reference {
    publisher = "citrix"
    offer     = "netscalervpx-131"
    sku       = "netscalerbyol"
    version   = "latest"
  }
  
  tags = {
    Application = var.appname
	Terraform = "Yes"
  }
}