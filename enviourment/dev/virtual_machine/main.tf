data "azurerm_network_interface" "data_nic" {
  name                = var.nic_name
  resource_group_name = var.rg_name
}

    resource "azurerm_linux_virtual_machine" "ravi-vm" {
    name                = var.vm_name
    resource_group_name = var.rg_name
    location            = var.rg_location
    size                = "Standard_D2s_v3"
    admin_username      = data.azurerm_key_vault_secret.ravinderuser.value
    admin_password =     data.azurerm_key_vault_secret.ravinderpass.value
    disable_password_authentication = false
    network_interface_ids = [
    data.azurerm_network_interface.data_nic.id
  ]
  

custom_data = base64encode(<<EOF
#!/bin/bash
set -e

# Update packages
apt-get update -y

# Install nginx
apt-get install -y nginx

# Enable & start nginx
systemctl enable nginx
systemctl start nginx

# Create test page
echo "<h1>Nginx Installed Successfully on Azure VM</h1>" > /var/www/html/index.html
EOF
)


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


data "azurerm_key_vault" "ravinder-kv" {
  name                = "ravinder-kv"
  resource_group_name = "ravinder_storage"
}

data "azurerm_key_vault_secret" "ravinderuser" {
  name         = "ravinderuser"
  key_vault_id = data.azurerm_key_vault.ravinder-kv.id
}


data "azurerm_key_vault_secret" "ravinderpass" {
  name         = "ravinderpass"
  key_vault_id = data.azurerm_key_vault.ravinder-kv.id
}






# data "azurerm_key_vault" "ravinder-keyvault" {
#   name                = "ravinder-keyvault"
#   resource_group_name = "ravinder_storage"
# }

# # output "vault_uri" {
# #   value = data.azurerm_key_vault.example.vault_uri
# # }

# data "azurerm_key_vault_secret" "ravinder-username" {
#   name         = "ravinder-username"
#   key_vault_id = data.azurerm_key_vault.ravinder-keyvault.id
# }

# data "azurerm_key_vault_secret" "ravinder-password" {
#   name         = "ravinder-password"
#   key_vault_id = data.azurerm_key_vault.ravinder-keyvault.id
# }


# output "secret_value" {
#   value     = data.azurerm_key_vault_secret.example.value
#   sensitive = true
# }
 
#######################################

output "vm_name" {
  value = azurerm_linux_virtual_machine.ravi-vm.name
}

output "vm_password" {
  value     = azurerm_linux_virtual_machine.ravi-vm.admin_password
}