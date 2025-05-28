### General ###
variable "workload" {
  type = string
}

variable "location" {
  type = string
}

variable "subscription_id" {
  type = string
}

### Container Registry ###
variable "acr_sku" {
  type = string
}

variable "acr_admin_enabled" {
  type = bool
}

### VM ###
variable "vm_admin_username" {
  type = string
}

variable "vm_public_key_path" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "vm_image_publisher" {
  type = string
}

variable "vm_image_offer" {
  type = string
}

variable "vm_image_sku" {
  type = string
}

variable "vm_image_version" {
  type = string
}
