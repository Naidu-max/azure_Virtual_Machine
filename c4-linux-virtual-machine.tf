# Resource: Azure Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "mylinuxvm" {
  name = "mylinuxvm-1"
  computer_name = "devlinux-vm1"  # Hostname of the VM
  resource_group_name = azurerm_resource_group.myrg.name
  location = azurerm_resource_group.myrg.location
  size = "Standard_D2s_v3"
  admin_username = "azureuser"
  network_interface_ids = [ azurerm_network_interface.myvmnic.id ]
  admin_ssh_key {
    username = "azureuser"
    public_key = file("${path.module}/ssh-keys/terraform-azure.pub")
  }
  os_disk {
    name = "osdisk"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "RedHat"
    offer = "RHEL"
    sku = "83-gen2"
    version = "latest"
  }
  custom_data = filebase64("${path.module}/app-scripts/app1-cloud-init.txt")

 connection {
    type = "ssh"
    host = self.public_ip_address # Understand what is "self"
    user = self.admin_username
    private_key = file("${path.module}/ssh-keys/terraform-azure.pem")
  }  



# Remote-exec Provisioner-1: Copies the file to Apache Webserver /var/www/html directory
  provisioner "remote-exec" {
    on_failure = continue
    inline = [
      "sleep 120", # Will sleep for 120 seconds to ensure Apache webserver is provisioned using custom_data
      "sudo systemctl start httpd"
      
    ]
  }



}
resource "azurerm_network_security_group" "nsg" {
  name = "nsg"
  resource_group_name = azurerm_resource_group.myrg.name
  location = azurerm_resource_group.myrg.location
  
  
}
resource "azurerm_network_security_group" "web_nsg" {
  name                = "web-nsg"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

# Allow HTTP (Port 80)
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "Allow-HTTP-80"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myrg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Allow HTTPS (Port 443)
resource "azurerm_network_security_rule" "allow_https" {
  name                        = "Allow-HTTPS-443"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myrg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_SHH" {
  name                        = "Allow-ssh-22"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.myrg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}


resource "azurerm_network_interface_security_group_association" "nsg_nic" {
 network_interface_id = azurerm_network_interface.myvmnic.id
 network_security_group_id = azurerm_network_security_group.nsg.id
  
}

