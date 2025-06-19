output "vm" {
    value = azurerm_virtual_machine.vm.name
  }

  output "vnet" {
    value = azurerm_virtual_network.Vnet.name
  }

  output "subnet" {
    value = azurerm_subnet.internal.name
  }

  output "public-ip" {
    value = azurerm_public_ip.pip.ip_address
    
  }

  