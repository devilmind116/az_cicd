resource "azurerm_resource_group" "cicd_rg" {
name     = "cicd_rg"
location = "centralindia"
}

resource "azurerm_virtual_network" "cicd_vn" {
name                = "cicd_vn"
address_space       = ["10.0.0.0/16"]
location            = azurerm_resource_group.cicd_rg.location
resource_group_name = azurerm_resource_group.cicd_rg.name
}

resource "azurerm_subnet" "cicd_subnet" {
name                 = "cicd_subnet"
resource_group_name  = azurerm_resource_group.cicd_rg.name
virtual_network_name = azurerm_virtual_network.cicd_vn.name
address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "cp_nic" {
count               = length(var.nic_names)
name                = "${var.nic_names[count.index]}"
location            = azurerm_resource_group.cicd_rg.location
resource_group_name = azurerm_resource_group.cicd_rg.name

ip_configuration {
name                          = "internal"
subnet_id                     = azurerm_subnet.cicd_subnet.id
private_ip_address_allocation = "Dynamic"
}
}

resource "azurerm_linux_virtual_machine" "control-pane" {
count               = length(var.vm_names)
name                = "${var.vm_names[count.index]}"
resource_group_name = azurerm_resource_group.cicd_rg.name
location            = azurerm_resource_group.cicd_rg.location
size                = "Standard_DS3_v2"
admin_username      = "cicd"
network_interface_ids = [
azurerm_network_interface.cp_nic[count.index].id,
]

admin_ssh_key {
username   = "cicd"
public_key = file("~/.ssh/id_rsa.pub")
}

os_disk {
caching              = "ReadWrite"
storage_account_type = "Standard_LRS"
}

source_image_reference {
publisher = "Canonical"
offer     = "0001-com-ubuntu-server-jammy"
}
}
