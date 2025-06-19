

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "Vnet" {
  name                = "my-Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name              = "my-nsg"
  location          =  data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  
}

resource "azurerm_network_security_rule" "nsg-rule" {
  name              = "Allow-port-22"
  priority          = 100
  direction         = "Inbound"  
  access =  "Allow"
  source_port_range = "*"
  source_address_prefix = "*"
  destination_port_range = 22
  destination_address_prefix = "*"
  protocol = "Tcp"  
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name = data.azurerm_resource_group.rg.name

}

resource "azurerm_network_interface" "nic" {
  name                = "my-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "pub-ip-vm"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = "Static"
}


resource "azurerm_virtual_machine" "vm" {
  name                  = "my-vm"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B1s"
  

  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}