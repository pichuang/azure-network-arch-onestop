# https://blog.pichuang.com.tw/azure-subnets.html

resource "azurerm_virtual_network" "vnet-hub" {
  address_space       = ["10.73.30.0/24"]
  location            = var.lab-location
  name                = "vnet-hub"
  resource_group_name = var.lab-rg
  tags                = var.tags
}

resource "azurerm_subnet" "azurefirewallsubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  address_prefixes     = ["10.73.30.0/26"]
}

resource "azurerm_subnet" "routeserversubnet" {
  name                 = "RouteServerSubnet"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  address_prefixes     = ["10.73.30.64/26"]
}

resource "azurerm_subnet" "gatewaysubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  address_prefixes     = ["10.73.30.128/27"]
}

resource "azurerm_subnet" "subnet-hub" {
  name                 = "subnet-hub"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  address_prefixes     = ["10.73.30.160/27"]
}

resource "azurerm_subnet" "azurebastionsubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  address_prefixes     = ["10.73.30.224/27"]
}

#
# VNet Peering to vnet-spoke1
#
# Ref: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering

resource "azurerm_virtual_network_peering" "peer-hub-to-spoke1" {
  name                      = "peer-hub-to-spoke1"
  resource_group_name       = var.lab-rg
  virtual_network_name      = azurerm_virtual_network.vnet-hub.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-spoke1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  use_remote_gateways = false
  allow_gateway_transit = true

  depends_on = [
    azurerm_virtual_network_gateway.vng-s2svpn
  ]
}

resource "azurerm_virtual_network_peering" "peer-hub-to-spoke2" {
  name                      = "peer-hub-to-spoke2"
  resource_group_name       = var.lab-rg
  virtual_network_name      = azurerm_virtual_network.vnet-hub.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-spoke2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  use_remote_gateways = false
  allow_gateway_transit = true

  depends_on = [
    azurerm_virtual_network_gateway.vng-s2svpn
  ]
}

#
# NAT Gateway
#
# resource "azurerm_public_ip" "pip-natgateway" {
#   name                = "pip-natgateway"
#   location            = var.lab-location
#   resource_group_name = var.lab-rg
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   zones               = ["1"]
# }

# # Ref: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway
# resource "azurerm_nat_gateway" "hub-natgw" {
#   name                    = "hub-natgw"
#   location                = var.lab-location
#   resource_group_name     = var.lab-rg
#   sku_name                = "Standard"
#   idle_timeout_in_minutes = 4
#   zones                   = ["1"]
# }

# resource "azurerm_nat_gateway_public_ip_association" "bridge-natgw-and-pip" {
#   nat_gateway_id       = azurerm_nat_gateway.hub-natgw.id
#   public_ip_address_id = azurerm_public_ip.pip-natgateway.id
# }

#
# Azure Bastion
#

resource "azurerm_public_ip" "pip-bastion" {
  name                = "pip-bastion"
  location            = var.lab-location
  resource_group_name = var.lab-rg
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bastion"
  location            = var.lab-location
  resource_group_name = var.lab-rg

  sku = "Standard"
  tunneling_enabled = true
  file_copy_enabled = true
  copy_paste_enabled = true
  ip_connect_enabled = true
  shareable_link_enabled = true
  scale_units = 2

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.azurebastionsubnet.id
    public_ip_address_id = azurerm_public_ip.pip-bastion.id
  }
}

#
# Azure VNG Gateway
#

resource "azurerm_public_ip" "pip-vpn1" {
  name                = "pip-vpn1"
  location            = var.lab-location
  resource_group_name = var.lab-rg
  allocation_method = "Dynamic"
}

# resource "azurerm_public_ip" "pip-vpn2" {
#   name                = "pip-vpn2"
#   location            = var.lab-location
#   resource_group_name = var.lab-rg
#   allocation_method = "Dynamic"
# }

resource "azurerm_virtual_network_gateway" "vng-s2svpn" {
  name                = "vng-s2svpn"
  location            = var.lab-location
  resource_group_name = var.lab-rg

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig1"
    public_ip_address_id          = azurerm_public_ip.pip-vpn1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gatewaysubnet.id
  }

  # ip_configuration {
  #   name                          = "vnetGatewayConfig2"
  #   public_ip_address_id          = azurerm_public_ip.pip-vpn2.id
  #   private_ip_address_allocation = "Dynamic"
  #   subnet_id                     = azurerm_subnet.gatewaysubnet.id
  # }

}


#
# Create a VM in the subnet-hub
#

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg-hub" {
  name                = "nsg-hub"
  location            = var.lab-location
  resource_group_name = var.lab-rg

  security_rule {
    name                       = "Allow-inbound-ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface card
resource "azurerm_network_interface" "nic-hub" {
  name                = "nic-hub"
  location            = var.lab-location
  resource_group_name = var.lab-rg

  ip_configuration {
    name                          = "ipconfig-nic-hub"
    subnet_id                     = azurerm_subnet.subnet-hub.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.73.30.164"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "connect-nsg-and-nic-hub" {
  network_interface_id      = azurerm_network_interface.nic-hub.id
  network_security_group_id = azurerm_network_security_group.nsg-hub.id
}

resource "azurerm_linux_virtual_machine" "vm-hub" {
  name                  = "vm-hub"
  location              = var.lab-location
  resource_group_name   = var.lab-rg
  network_interface_ids = [azurerm_network_interface.nic-hub.id]
  size                  = "Standard_DC2s_v3"

  os_disk {
    name                 = "disk-vm-hub"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-minimal-jammy"
    sku       = "minimal-22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "vm-hub"
  admin_username                  = var.admin_username
  disable_password_authentication = false
  admin_password = var.admin_password

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/azure-rsa.pub")
  }

  custom_data = filebase64("cloud-init.txt")

}
