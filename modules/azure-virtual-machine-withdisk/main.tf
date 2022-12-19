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
  license_type              = "Windows_Server"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
	  name                 = "${var.servername}_OSdisk"	
    disk_size_gb         = "64"
  }

  source_image_reference {
    publisher = "center-for-internet-security-inc"
    offer     = "cis-windows-server-2022-l1"
    sku       = "cis-windows-server-2022-l1-gen2"
    version   = "latest"
  }
  
  plan {
    name      = "cis-windows-server-2022-l1-gen2"
    product   = "cis-windows-server-2022-l1"
    publisher = "center-for-internet-security-inc"
  }

  tags = {
    EpicApp = var.epicappname
	Terraform = "Yes"
  }
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk>
resource "azurerm_managed_disk" "ddisk" {
  name                          = "${var.servername}_datadisk_0"
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
resource "azurerm_virtual_machine_data_disk_attachment" "ddiskattach" {
  managed_disk_id    = azurerm_managed_disk.ddisk.id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun                = "0"
  caching            = "None"
}

##<https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_test_global_vm_shutdown_schedule>
resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown" {
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  location           = var.location
  enabled            = var.shutdown

  daily_recurrence_time = "1800"
  timezone              = var.timezone

  notification_settings {
    enabled         = false
    time_in_minutes = "60"
    webhook_url     = "https://sample-webhook-url.example.com"
  }
}

## <https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension>
resource "azurerm_virtual_machine_extension" "postdeployconfig" {
    
  name                 = "PostDeployConfig"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

   settings = <<SETTINGS
    {
      "fileUris": ["https://tvcepicrofiles.blob.core.windows.net/scripts/Set-KuiperFirewall.ps1"]
    }
SETTINGS

    protected_settings = <<PROTECTED_SETTINGS
        {
          "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File Set-KuiperFirewall.ps1",     
          "storageAccountName": "tvcepicrofiles",
          "storageAccountKey": "x4Y3KtQyHiJ1N5vBVInWC3pv2waKRNStlykt/m5mRK2QDcQGPB5fHbZpH7p14ZcpvoSfnzhyAnOd+AStDaa5iA=="
        }
PROTECTED_SETTINGS

  tags = {
	  Terraform = "Yes"
  }
}
