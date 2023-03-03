resource "azurerm_virtual_network" "vnet-spoke2" {
  address_space       = ["10.73.33.0/24"]
  location            = var.lab-location
  name                = "vnet-spoke2"
  resource_group_name = var.lab-rg
  tags                = var.tags
}

resource "azurerm_subnet" "subnet-spoke2" {
  name                 = "subnet-spoke2"
  resource_group_name  = var.lab-rg
  virtual_network_name = azurerm_virtual_network.vnet-spoke2.name
  address_prefixes     = ["10.73.33.0/26"]
}

#
# VNet Peering to vnet-hub-japeneast
#
# Ref: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering

resource "azurerm_virtual_network_peering" "peer-spoke2-to-hub" {
  name                         = "peer-spoke2-to-hub"
  resource_group_name          = var.lab-rg
  virtual_network_name         = azurerm_virtual_network.vnet-spoke2.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = true
  allow_gateway_transit        = false

  depends_on = [
    azurerm_virtual_network_gateway.vng-s2svpn
  ]
}

#
# Create Route Table
#

resource "azurerm_route_table" "rt-for-spoke2" {
  name                          = "rt-for-spoke2"
  location                      = var.lab-location
  resource_group_name           = var.lab-rg
  disable_bgp_route_propagation = false

  route {
    name                   = "route-to-azfw"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
  }

  depends_on = [
    azurerm_firewall.firewall
  ]
}

resource "azurerm_subnet_route_table_association" "associate-rt-to-spoke2-and-subnet-spoke2" {
  subnet_id      = azurerm_subnet.subnet-spoke2.id
  route_table_id = azurerm_route_table.rt-for-spoke2.id
}



#
# Create a VM in the subnet-spoke2
#

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg-spoke2" {
  name                = "nsg-spoke2"
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
resource "azurerm_network_interface" "nic-spoke2" {
  name                = "nic-spoke2"
  location            = var.lab-location
  resource_group_name = var.lab-rg

  ip_configuration {
    name                          = "ipconfig-nic-spoke2"
    subnet_id                     = azurerm_subnet.subnet-spoke2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.73.33.4"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "connect-nsg-and-nic-spoke2" {
  network_interface_id      = azurerm_network_interface.nic-spoke2.id
  network_security_group_id = azurerm_network_security_group.nsg-spoke2.id
}

resource "azurerm_linux_virtual_machine" "vm-spoke2" {
  name                  = "vm-spoke2"
  location              = var.lab-location
  resource_group_name   = var.lab-rg
  network_interface_ids = [azurerm_network_interface.nic-spoke2.id]
  size                  = "Standard_DC2s_v3"

  os_disk {
    name                 = "disk-vm-spoke2"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-minimal-jammy"
    sku       = "minimal-22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "vm-spoke2"
  admin_username                  = var.admin_username
  disable_password_authentication = false
  admin_password                  = var.admin_password

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/azure-rsa.pub")
  }

  custom_data = filebase64("cloud-init.txt")

}