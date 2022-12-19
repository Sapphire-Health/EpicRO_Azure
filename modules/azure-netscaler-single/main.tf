## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface>
resource "azurerm_network_interface" "nic" {
  name                = "${var.servername}_nic"
  location            = var.location
  resource_group_name = var.rgname
  enable_accelerated_networking = "true"    

  ip_configuration {
    name                          = "mgmt"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
	  private_ip_address            = var.mgmt_ip_address
    primary                       = "true"
  }

  ip_configuration {
    name                          = "backend"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
	  private_ip_address            = var.back_ip_address
    primary                       = "false"    
  }

  ip_configuration {
    name                          = "frontend"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
	  private_ip_address            = var.front_ip_address
    primary                       = "false"    
  }  

  tags = {
    Application = var.appname
	  Terraform = "Yes"
  }
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine>
resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.servername
  resource_group_name = var.rgname
  location            = var.location
  size                = var.vm_size
  availability_set_id = var.aset_id  
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = "false"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
	  name                 = "${var.servername}_OSdisk"	
  }

  source_image_reference {
    publisher = "citrix"
    offer     = "netscalervpx-131"
    sku       = "netscalerbyol"
    version   = "131.33.52"
  }

  plan {
    name      = "netscalerbyol"
    product   = "netscalervpx-131"
    publisher = "citrix"
  }

  tags = {
    Application = var.appname
	  Terraform = "Yes"
  }
}
