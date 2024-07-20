libvirt_uri = "qemu:///system"

pool              = "default"
vm_base_image_uri = "/var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2"
network_name      = "default"

vms = [
  {
    name           = "freeipa1"
    vcpu           = 4
    memory         = 16000                    # in MiB
    disk           = 100 * 1024 * 1024 * 1024 # 100 GB
    ip             = "192.168.122.11"
    cloudinit_file = "cloud_init.cfg"
  },
  {
    name           = "freeipa2"
    vcpu           = 4
    memory         = 16000                    # in MiB
    disk           = 100 * 1024 * 1024 * 1024 # 100 GB
    ip             = "192.168.122.12"
    cloudinit_file = "cloud_init.cfg"
  },
  {
    name           = "freeipa3"
    vcpu           = 4
    memory         = 16000                    # in MiB
    disk           = 100 * 1024 * 1024 * 1024 # 100 GB
    ip             = "192.168.122.13"
    cloudinit_file = "cloud_init.cfg"
  },
]
