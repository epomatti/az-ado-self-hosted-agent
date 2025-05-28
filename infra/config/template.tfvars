# General
subscription_id = "your-subscription-id"
location        = "brazilsouth"
workload        = "contoso"

# Container Registry
acr_sku           = "Premium"
acr_admin_enabled = true

# Virtual Machine
vm_admin_username  = "azureuser"
vm_public_key_path = ".keys/tmp_key.pub"
vm_size            = "Standard_B2ls_v2"
vm_image_publisher = "canonical"
vm_image_offer     = "ubuntu-24_04-lts"
vm_image_sku       = "server"
vm_image_version   = "latest"
