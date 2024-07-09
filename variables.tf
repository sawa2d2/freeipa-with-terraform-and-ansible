variable "libvirt_uri" {
  type    = string
  default = "qemu:///system"
}

variable "vm_base_image_uri" {
  type = string
}

variable "network_name" {
  type    = string
  default = "default"
}

variable "cidr" {
  type    = string
  default = "192.168.122.0/24"
}

variable "gateway" {
  type    = string
  default = "192.168.122.1"
}

variable "nameservers" {
  type    = list(string)
  default = ["192.168.122.1"]
}


variable "pool" {
  type    = string
  default = "default"
}

variable "vms" {
  type = list(
    object({
      name           = string
      vcpu           = number
      memory         = number
      disk           = number
      ip             = string
      cloudinit_file = string
    })
  )
}
