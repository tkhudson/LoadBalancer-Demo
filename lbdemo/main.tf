locals {
  location  = "East US"
  azrg      = azurerm_resource_group.lbdemo-rg.name
  vnetname  = azurerm_virtual_network.lbdemo-vnet.name
  publicip1 = azurerm_public_ip.lbdemo-ip-1.id
  publicip2 = azurerm_public_ip.lbdemo-ip-2.id
  publicip3 = azurerm_public_ip.lbdemo-ip-3.id
  publicip  = azurerm_public_ip.lbdemo-ip.id
  sbn1      = azurerm_subnet.lbdemo-sbn-1.id
  sbn2      = azurerm_subnet.lbdemo-sbn-2.id
  sbn3      = azurerm_subnet.lbdemo-sbn-3.id

}

## the following resources are deployed not in order of time, but of group organization.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.30.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lbdemo-rg" {
  name     = "lbdemo-rg"
  location = local.location

  tags = {
    environment = "demodev"
  }
}

resource "azurerm_virtual_network" "lbdemo-vnet" {
  name                = "lbdemo-vnet"
  resource_group_name = local.azrg
  location            = local.location
  address_space       = ["10.124.0.0/16"]

  tags = {
    "environment" = "demodev"
  }
}

resource "azurerm_public_ip" "lbdemo-ip" {
  name                = "lbdemo-ip"
  resource_group_name = local.azrg
  location            = local.location
  allocation_method   = "Static"

  tags = {
    environment = "demodev"
  }
}

resource "azurerm_public_ip" "lbdemo-ip-1" {
  name                = "lbdemo-ip-1"
  resource_group_name = local.azrg
  location            = local.location
  allocation_method   = "Static"

  tags = {
    environment = "sub1"
  }
}

resource "azurerm_public_ip" "lbdemo-ip-2" {
  name                = "lbdemo-ip-2"
  resource_group_name = local.azrg
  location            = local.location
  allocation_method   = "Static"

  tags = {
    environment = "sub2"
  }
}

resource "azurerm_public_ip" "lbdemo-ip-3" {
  name                = "lbdemo-ip-3"
  resource_group_name = local.azrg
  location            = local.location
  allocation_method   = "Static"

  tags = {
    environment = "sub3"
  }
}

resource "azurerm_subnet" "lbdemo-sbn-1" {
  name                 = "lbdemo-sbn-1"
  resource_group_name  = local.azrg
  virtual_network_name = local.vnetname
  address_prefixes     = ["10.124.1.0/24"]
}

resource "azurerm_network_interface" "lbdemo-nic-1" {
  name                = "lbdemo-nic-1"
  location            = local.location
  resource_group_name = local.azrg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.sbn1
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = local.publicip1
  }

  tags = {
    environment = "sub1"
  }
}

resource "azurerm_linux_virtual_machine" "sbn1-vm" {
  name                            = "sbn1-vm"
  resource_group_name             = local.azrg
  location                        = local.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "demopass1!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.lbdemo-nic-1.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_subnet" "lbdemo-sbn-2" {
  name                 = "lbdemo-sbn-2"
  resource_group_name  = local.azrg
  virtual_network_name = local.vnetname
  address_prefixes     = ["10.124.2.0/24"]
}

resource "azurerm_network_interface" "lbdemo-nic-2" {
  name                = "lbdemo-nic-2"
  location            = local.location
  resource_group_name = local.azrg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.sbn2
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = local.publicip2
  }

  tags = {
    environment = "sub2"
  }
}

resource "azurerm_subnet" "lbdemo-sbn-3" {
  name                 = "lbdemo-sbn-3"
  resource_group_name  = local.azrg
  virtual_network_name = local.vnetname
  address_prefixes     = ["10.124.3.0/24"]
}

resource "azurerm_network_interface" "lbdemo-nic-3" {
  name                = "lbdemo-nic-3"
  location            = local.location
  resource_group_name = local.azrg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.sbn3
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = local.publicip3
  }

  tags = {
    environment = "sub3"
  }
}

resource "azurerm_network_security_group" "lbdemo-sg" {
  name                = "lbdemo-sg"
  location            = local.location
  resource_group_name = local.azrg

  tags = {
    environment = "demodev"
  }
}

resource "azurerm_network_security_rule" "lbdemo-dev-rule" {
  name                        = "lbdemo-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = local.azrg
  network_security_group_name = azurerm_network_security_group.lbdemo-sg.name
}

resource "azurerm_subnet_network_security_group_association" "subnetassociation1" {
  subnet_id                 = azurerm_subnet.lbdemo-sbn-1.id
  network_security_group_id = azurerm_network_security_group.lbdemo-sg.id
}

resource "azurerm_subnet_network_security_group_association" "subnetassociation2" {
  subnet_id                 = azurerm_subnet.lbdemo-sbn-2.id
  network_security_group_id = azurerm_network_security_group.lbdemo-sg.id
}

resource "azurerm_subnet_network_security_group_association" "subnetassociation3" {
  subnet_id                 = azurerm_subnet.lbdemo-sbn-3.id
  network_security_group_id = azurerm_network_security_group.lbdemo-sg.id
}


resource "azurerm_lb" "lbdemo-lb" {
  name                = "lbdemo-lb"
  location            = local.location
  resource_group_name = local.azrg

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = local.publicip
  }

  tags = {
    "environment" = "demodev"
  }
}









