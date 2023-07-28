### General ###
variable "workload" {
  type    = string
  default = "myapp"
}

variable "location" {
  type    = string
  default = "brazilsouth"
}

### VM ###
variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}
