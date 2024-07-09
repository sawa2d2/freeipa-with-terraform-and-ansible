terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
  uri = var.libvirt_uri
}

locals {
  cidr_splitted      = split("/", var.cidr)
  cidr_subnet        = local.cidr_splitted[0]
  cidr_prefix        = local.cidr_splitted[1]
  nameservers_string = "[\"${join("\", \"", var.nameservers)}\"]"

  # Auto-calculate mac address from IP
  ips_parts = [for vm in var.vms : split(".", vm.ip)]
  mac_addrs = [
    for ip_parts in local.ips_parts : format(
      "52:54:00:%02X:%02X:%02X",
      tonumber(ip_parts[1]),
      tonumber(ip_parts[2]),
      tonumber(ip_parts[3])
    )
  ]
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = length(var.vms)
  name  = "commoninit_${var.vms[count.index].name}.iso"
  user_data = templatefile(var.vms[count.index].cloudinit_file, {
    hostname = var.vms[count.index].name
  })
  pool = var.pool
}

resource "libvirt_domain" "vm" {
  count  = length(var.vms)
  name   = var.vms[count.index].name
  vcpu   = var.vms[count.index].vcpu
  memory = var.vms[count.index].memory

  disk {
    volume_id = libvirt_volume.system[count.index].id
    scsi      = "true"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id
  autostart = true

  network_interface {
    network_name = var.network_name
    addresses    = [var.vms[count.index].ip]
    mac          = local.mac_addrs[count.index]
  }

  cpu {
    mode = "host-passthrough"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }

  # Makes the tty0 available via `virsh console`
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

resource "libvirt_volume" "system" {
  count          = length(var.vms)
  name           = "${var.vms[count.index].name}_system.qcow2"
  pool           = var.pool
  format         = "qcow2"
  base_volume_id = var.vm_base_image_uri
  size           = var.vms[count.index].disk
}
