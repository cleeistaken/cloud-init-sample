#
# Terraform
#
terraform {
  required_version = ">= 1.3.4"
  required_providers {
    htpasswd = {
      source = "loafoe/htpasswd"
    }
  }
}

#
# vSphere Provider
#
provider "vsphere" {
  vsphere_server = var.vcenter_server
  user = var.vcenter_user
  password = var.vcenter_password
  allow_unverified_ssl = var.vcenter_insecure_ssl
}

#
#  htpasswd provider
#  https://registry.terraform.io/providers/loafoe/htpasswd/latest/docs
#
provider "htpasswd" {
}

resource "random_password" "password" {
  length = 20
}

# htpasswd configuration
resource "random_password" "salt" {
  length = 8
}

resource "htpasswd_password" "cloud_init_password_hash" {
  password = length(var.cloud_init_password) > 0 ? var.cloud_init_password : random_password.password.result
  salt = random_password.salt.result
}

#
# vSphere
#
data "vsphere_datacenter" "my_datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "my_compute_cluster" {
  name = var.vsphere_compute_cluster
  datacenter_id = data.vsphere_datacenter.my_datacenter.id
}

data "vsphere_datastore" "my_datastore" {
  name = var.vsphere_datastore_name
  datacenter_id = data.vsphere_datacenter.my_datacenter.id

}

data "vsphere_network" "my_network" {
  count = length(var.vsphere_networks)
  name = var.vsphere_networks[count.index].name
  datacenter_id = data.vsphere_datacenter.my_datacenter.id
}

resource "vsphere_resource_pool" "my_resource_pool" {
  name = var.vsphere_resource_pool_name
  parent_resource_pool_id = data.vsphere_compute_cluster.my_compute_cluster.resource_pool_id
}

#
# Content Library
#
resource "vsphere_content_library" "my_content_library" {
  name            = var.vsphere_content_library_name
  description     = var.vsphere_content_library_description
  storage_backing = [data.vsphere_datastore.my_datastore.id]
}

resource "vsphere_content_library_item" "my_content_library_item" {
  name        = var.vsphere_content_library_item_name
  description = var.vsphere_content_library_item_description
  library_id  = vsphere_content_library.my_content_library.id
  file_url    = var.vsphere_content_library_item_file_url
}

#
# Read and parse current user public id_rsa key
#
locals {
  raw_lines = [
  for line in split("\n", file(var.rsa_public_key_file)) :
  trimspace(line)
  ]
  ssh_authorized_keys = [
  for line in local.raw_lines :
  line if length(line) > 0 && substr(line, 0, 1) != "#"
  ]
}

#
# Cloud-init
# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config
#

data "template_cloudinit_config" "userdata" {
  gzip = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud_init_userdata.yml.tpl", {
      username = var.cloud_init_username
      password = htpasswd_password.cloud_init_password_hash.sha512
      primary_group = var.cloud_init_primary_group
      groups = var.cloud_init_groups
      shell: var.cloud_init_user_shell
      ssh_key_list = element(local.ssh_authorized_keys, 0)
      data_disks_count = var.vm_disk_data_count
    })
  }
}

#
# VM
#

resource "vsphere_virtual_machine" "my_vm" {
  count = var.vm_count
  name = format("%s-%02d", var.vm_name_prefix, count.index + 1)

  # Template boot mode (efi or bios)
  firmware = var.vm_firmware

  # Set the hardware version
  hardware_version = var.vm_hardware_version

  # Resource pool for created VM
  resource_pool_id = vsphere_resource_pool.my_resource_pool.id

  # Datastore and Storage Policy
  datastore_id = data.vsphere_datastore.my_datastore.id

  num_cpus = var.vm_cpu_count
  memory = var.vm_mem_size_mb

  dynamic "network_interface" {
    for_each = data.vsphere_network.my_network
    content {
      network_id = network_interface.value.id
      ovf_mapping = var.vsphere_networks[index(data.vsphere_network.my_network, network_interface.value)].ovf_mapping
    }
  }

  # OS Disk
  disk {
    label = format("%s-%02d-%s", var.vm_name_prefix, count.index + 1, "os")
    size = var.vm_disk_os_size_gb
    unit_number = 0
  }

  # SCSI controllers
  scsi_controller_count = max(1, min(4, var.vm_disk_data_count + 1))

  # scsi0:0-14 are unit numbers 0-14
  # scsi1:0-14 are unit numbers 15-29
  # scsi2:0-14 are unit numbers 30-44
  # scsi3:0-14 are unit numbers 45-59
   dynamic "disk" {
    for_each = range(1, var.vm_disk_data_count + 1)

    content {
      label             = format("%s-%02d-%s-disk%d", var.vm_name_prefix, count.index + 1, "data", disk.value)
      size              = var.vm_disk_data_size_gb
      unit_number       = 14 + (((disk.value - 1) % 3) * 14) + disk.value
    }
  }

  clone {
    template_uuid = vsphere_content_library_item.my_content_library_item.id

    customize {
      linux_options {
        host_name = format("%s-%02d", var.vm_name_prefix, count.index + 1)
        domain = var.vm_network_domain
      }

      dynamic "network_interface" {
        for_each = var.vm_network_ipv4_ips[count.index]
          content {
            ipv4_address = network_interface.value.ipv4_address
            ipv4_netmask = network_interface.value.ipv4_netmask
        }
      }
      ipv4_gateway = var.vm_network_ipv4_gateway
      dns_server_list = var.vm_network_ipv4_dns_servers
    }
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
    ]
  }

  # https://github.com/tenthirtyam/terrafom-examples-vmware/tree/main/vsphere/vsphere-virtual-machine/clone-template-linux-cloud-init
  extra_config = {
      "guestinfo.userdata" = "${data.template_cloudinit_config.userdata.rendered}"
      "guestinfo.userdata.encoding" = "gzip+base64"
    }
}
