
resource "azurerm_resource_group" "example" {
  name     = "terraformlab-rg"
  location = "West US"

  tags = {
    environment = "Lab"
  }
}

# Virtual Network Resource
resource "azurerm_virtual_network" "main" {
  name                = "terraformlab-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet Resource
resource "azurerm_subnet" "example1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Additional Subnet Resource
resource "azurerm_subnet" "example2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Public IP Resource
resource "azurerm_public_ip" "example" {
  name                = "terraformlab-pip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "Lab"
  }
}

# Network Interface Resource
resource "azurerm_network_interface" "example" {
  name                = "terraformlab-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "testconfiguration"
    subnet_id                     = azurerm_subnet.example1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }

  tags = {
    environment = "Lab"
  }
}

# Network Security Group Resource
resource "azurerm_network_security_group" "example" {
  name                = "terraformlab-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Lab"
  }
}

# Network Interface Security Group Association
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}


# Virtual Machine Resource

resource "azurerm_virtual_machine" "main" {
  name                  = "terraformlab-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example.id]
  vm_size               = "Standard_B1ls"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

# OS Profile Config for Windows

 os_profile_windows_config {
    provision_vm_agent = true
    enable_automatic_upgrades = true
  }
  
#OS Configuration for Linux
# Uncomment this block to configure Linux VM settings

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }
  tags = {
    environment = "Lab"
  }
}