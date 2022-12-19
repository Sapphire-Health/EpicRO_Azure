## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface>
resource "azurerm_network_interface" "nic" {
  name                          = "${var.servername}_nic"
  location                      = var.location
  resource_group_name           = var.rgname
  enable_accelerated_networking = "true"
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
	  private_ip_address            = var.ip_address
	
  }
  
  tags = {
    EpicApp = var.epicappname
	  Terraform = "Yes"
  }
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine>
resource "azurerm_windows_virtual_machine" "vm" {
  name                      = var.servername
  resource_group_name       = var.rgname
  location                  = var.location
  size                      = var.vm_size
  availability_set_id       = var.aset_id
  admin_username            = var.admin_username
  admin_password            = var.admin_password
  timezone                  = var.timezone
  enable_automatic_updates  = var.enable_autoupdate
  patch_mode                = var.patch_mode
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
	  name                 = "${var.servername}_OSdisk"	
    disk_size_gb         = "128"     
  }

  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2019-ws2022"
    sku       = "standard-gen2"
    version   = "latest"
  }
  
  tags = {
    EpicApp = var.epicappname
	  Terraform = "Yes"
  }
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk>
resource "azurerm_managed_disk" "datadisk" {
  name                          = "${var.servername}_datadisk_1"
  location                      = var.location
  resource_group_name           = var.rgname
  storage_account_type          = "Premium_LRS"
  create_option                 = "Empty"
  disk_size_gb                  = var.datadisk_size
  public_network_access_enabled = "false"

  tags = {
    EpicApp = var.epicappname
	Terraform = "Yes"
  }
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment>
resource "azurerm_virtual_machine_data_disk_attachment" "datadiskattach" {
  managed_disk_id    = azurerm_managed_disk.datadisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "0"
  caching            = "None"
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk>
resource "azurerm_managed_disk" "logdisk" {
  name                          = "${var.servername}_logdisk_1"
  location                      = var.location
  resource_group_name           = var.rgname
  storage_account_type          = "Premium_LRS"
  create_option                 = "Empty"
  disk_size_gb                  = var.logdisk_size
  public_network_access_enabled = "false"

  tags = {
    EpicApp = var.epicappname
	Terraform = "Yes"
  }
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment>
resource "azurerm_virtual_machine_data_disk_attachment" "logdiskattach" {
  managed_disk_id    = azurerm_managed_disk.logdisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "1"
  caching            = "None"
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_machine>
resource "azurerm_mssql_virtual_machine" "sqlvm" {
  virtual_machine_id               = azurerm_windows_virtual_machine.vm.id
  sql_license_type                 = "AHUB"
  r_services_enabled               = false
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = var.sql_password
  sql_connectivity_update_username = var.sql_username

  auto_patching {
    day_of_week                            = "Saturday"
    maintenance_window_duration_in_minutes = 120
    maintenance_window_starting_hour       = 23
  }

  storage_configuration {
	disk_type = "NEW"
	storage_workload_type = "GENERAL"
	
    data_settings {
	    default_file_path = var.sql_datapath
		luns              = [0]
	}
	
	log_settings {
	    default_file_path = var.sql_logpath
		luns              = [1]
	}

  }
  depends_on = [azurerm_virtual_machine_data_disk_attachment.datadiskattach, azurerm_virtual_machine_data_disk_attachment.logdiskattach]
}
