variable "loc"{
    type        = string
}

resource "azurerm_linux_virtual_machine" "manager" {
  name                  = "manager"
  location              = azurerm_resource_group.rgmanager.location
  resource_group_name   = azurerm_resource_group.rgmanager.name
  size                  = "Standard_D3_v2"
  admin_username        = "cloudmss"
  admin_password        = "Password1234"
  network_interface_ids = [azurerm_network_interface.nic_manager.id]
  custom_data = base64encode(data.template_file.manager.rendered)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "checkpoint"
    offer     = "check-point-cg-r8030"
    sku       = "mgmt-byol"
    version   = "latest"
  }
  boot_diagnostics {
    #enabled = "true"
    storage_account_uri = azurerm_storage_account.hdmanager.primary_blob_endpoint
  }
}

resource "azurerm_resource_group" "rgmanager" {
  name = "rgt-manager"
  location = var.loc
}

resource "azurerm_virtual_network" "vnetmanager" {
  name                = "vnet-manager"
  resource_group_name = azurerm_resource_group.rgmanager.name
  address_space       = ["172.17.0.0/16"]
  location            = var.loc
}

resource "azurerm_subnet" "subnetmanager"  {
    name           = "Subnetmanager"
    resource_group_name  = azurerm_resource_group.rgmanager.name
    virtual_network_name = azurerm_virtual_network.vnetmanager.name
    address_prefixes = ["172.17.0.0/24"]
  }


resource "azurerm_public_ip" "publicamanager" {
    name                         = "publicamanager"
    location                     = var.loc
    resource_group_name          = azurerm_resource_group.rgmanager.name
    allocation_method            = "Dynamic"
}

resource "azurerm_network_interface" "nic_manager" {
    name                = "nicmanager"
    location            = var.loc
    resource_group_name  = azurerm_resource_group.rgmanager.name
    enable_ip_forwarding = "false"
	ip_configuration {
        name                          = "publicamgmt"
        subnet_id                     = azurerm_subnet.subnetmanager.id
        private_ip_address_allocation = "Static"
		private_ip_address = "172.17.0.4"
        primary = true
		public_ip_address_id = azurerm_public_ip.publicamanager.id
    }
}

resource "azurerm_storage_account" "hdmanager" {
    name                        = "hdmanager"
    resource_group_name         = azurerm_resource_group.rgmanager.name
    location                    = var.loc
    account_tier                = "Standard"
    account_replication_type    = "LRS"

}
/*
resource "azurerm_subnet_network_security_group_association" "vinculo1" {
  subnet_id                 = azurerm_subnet.subnetmanager.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

*/
data "template_file" "manager" {
  template = file("${path.module}/scriptmanager.sh")
}

output "idmanagerSbn" {
  value = azurerm_subnet.subnetmanager.id
}

output "rgmanager" {
  value = azurerm_resource_group.rgmanager.name
}

output "ipmanager"{
  value = azurerm_public_ip.publicamanager.ip_address
}
