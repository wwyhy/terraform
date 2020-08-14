# VPC
resource "azurerm_virtual_network" "myvnet" {
    name = "myVnet"
    address_space = ["10.110.0.0/16"]
    location = "eastasia"
    resource_group_name = azurerm_resource_group.rg.name
    tag = {
	environment = "terraform demo"
    }
}

# Subnet
resource "azurerm_subnet" "mysubnet" {
    name = "mySubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.myvnet.name
    address_prefix = ["10.110.0.0/24"]
}

# SG
resource "azure_network_security_group" "mysg" {
    name = "mySg"
    resource_group_name = azurerm_resource_group.rg.name
    security_rule {
        name = "SSH"
	priority = "1001"
	direction = "Inbound"
	access = "Allow"
	protocol = "Tcp"
	source_port_range = "*"
	destination_port_range = "22"
	source_address_prefix = "*"
	destination_address_prefix = "*"
    }
    tags = {
	environment = "terraform demo"
    }
}

# Public IP
resource "azurerm_public_ip" "myvmpublicip" {
    name = "myPublicIP"
    location = "eastasia"
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Dynamic"
    tags = {
	environment = "terraform demo"
    }
}

# NIC
resource "azurerm_network_interface" "myvmnic" {
    name = "myNic"
    location = "eastasia"
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
	name = "myNicConfiguration"
	subnet_id = azurerm_subnet.mysubnet.id
	private_ip_address_allocation = "Dynamic"
	public_ip_address_id = "azurerm_public_ip.myvmpublicip.id"	
    }
    tags = {
	environment = "terraform demo"
    }
}

# Link SG to netowrk interface
resource "azurerm_netowrk_interface_security_group_association" "linksg" {
    network_interface_id = "azurerm_network_interface.myvmnic.id"
    network_security_group_id = "azure_network_security_group.mysg.id"
}

# Storage account
resource "random_id" "randomId" {
    keepers = {
	resource_group = "azurerm_resource_group.rg.name"
    }
    bytes_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
    name = "diag${random_id.randomId.hex}"
    resource_group_name = azurerm_resource_group.rg.name
    location = "eastasia"
    account_replication_type = "LRS"
    account_tier = "Standard"
    tags = {
	environment = "terraform demo"
    }
}

# VM
resource "azurerm_linux_virtual_machine" "myVM" {
    name = "terraformvm"
    location = "eastasia"
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.myvmnic.id]
    size = "Standard_B1s"
    os_disk {
	name = "myOsDisk"
	caching = "ReadWrite"
	storage_account_type = "Standard_LRS"	
    }
    source_image_reference {
	publisher = "Redhat"
	offer = "Cetnos7"
	sku = "Centos-7.7"
	version = "latest"
    }
    computer_name = "myvm"
    admin_username = "centos"
    public_key = "file(./.ssh/)"
    tags = {
	environment = "terraform demo"
    }
}
