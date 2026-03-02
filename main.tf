# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "3107391c-1fb2-4525-ad56-f527fd836436"
  #resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}


# Create a resource group
resource "azurerm_resource_group" "tf_rg" {
  name     = "Az-Tf-Rg"
  location = "uksouth"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "tf_vnet" {
  name                = "tf-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.tf_rg.location
  resource_group_name = azurerm_resource_group.tf_rg.name
}

resource "azurerm_subnet" "tf_internal_sub" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.tf_rg.name
  virtual_network_name = azurerm_virtual_network.tf_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "tf_nic" {
  name                = "my-tf-nic"
  location            = azurerm_resource_group.tf_rg.location
  resource_group_name = azurerm_resource_group.tf_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tf_internal_sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf_public_ip.id
  }
}


resource "azurerm_public_ip" "tf_public_ip" {
  name                = "tf-public-ip"
  resource_group_name = azurerm_resource_group.tf_rg.name
  location            = azurerm_resource_group.tf_rg.location
  allocation_method   = "Static"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "tf_vm" {
  name                = "my-vm"
  resource_group_name = azurerm_resource_group.tf_rg.name
  location            = azurerm_resource_group.tf_rg.location
  size                = "Standard_D2ads_v7"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.tf_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "minimal"
    version   = "latest"
  }
}
resource "azurerm_network_security_group" "tf_nsg" {
  name                = "my-tf-nsg"
  location            = azurerm_resource_group.tf_rg.location
  resource_group_name = azurerm_resource_group.tf_rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "92.234.245.179/32"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface_security_group_association" "tf_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.tf_nic.id
  network_security_group_id = azurerm_network_security_group.tf_nsg.id
}

#creating a storage account
#AWS does not have storage account concept, AWS exposes all storage option as seperate services
resource "azurerm_storage_account" "tf_storage_acc" {
  name                     = "tztfstorageacckjoeri9e"
  resource_group_name      = azurerm_resource_group.tf_rg.name
  location                 = azurerm_resource_group.tf_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

#creating a blob container with blob only access
#equivalent to AWS S3 bucket
resource "azurerm_storage_container" "tf_blob_container" {
  name                  = "tz-tf-test-1"
  storage_account_name  = azurerm_storage_account.tf_storage_acc.name
  container_access_type = "blob"
}