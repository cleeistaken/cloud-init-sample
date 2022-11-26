#
# vCenter
#
variable "vcenter_server" {
  description = "vCenter Server hostname or IP"
  type = string
}

variable "vcenter_user" {
  description = "vCenter Server username"
  type = string
}

variable "vcenter_password" {
  description = "vCenter Server password"
  type = string
}

variable "vcenter_insecure_ssl" {
  description = "Allow insecure connection to the vCenter server (unverified SSL certificate)"
  type = bool
  default = false
}

#
# vSphere
#
variable "vsphere_datacenter" {
  description = "vsphere datacenter name"
  type = string
}

variable "vsphere_compute_cluster" {
  description = "vsphere compute cluster name"
  type = string
}

variable "vsphere_datastore_name" {
  description = "vsphere datastore name"
  type = string
}

variable "vsphere_resource_pool_name" {
  description = "vsphere resource pool name"
  type = string
}

variable "vsphere_networks" {
  type = list(object({
    name = string
    ovf_mapping = string
  }))
}

variable "vsphere_content_library_name" {
  description = "content library name"
  type = string
}

variable "vsphere_content_library_description" {
  description = "content library description"
  type = string
  default = "A new source of content"
}

variable "vsphere_content_library_item_name" {
  description = "name of the content library template"
  type = string
  default = "template"
}

variable "vsphere_content_library_item_description" {
  description = "description of the content library template"
  type = string
  default = "Template for terraform automation"
}

variable "vsphere_content_library_item_file_url" {
  description = "template url"
  type = string
}

#
# SSH
#
variable "rsa_public_key_file" {
  description = "RSA public key file"
  type = string
  default = "~/.ssh/id_rsa.pub"
}

#
# Cloud Init
#
variable "cloud_init_username" {
  description = "username for the user on the linux system"
  type = string
  default = "vmware"
}

variable "cloud_init_password" {
  description = "password for the user on the linux system"
  type = string
  default = "P@ssword123!"
}

variable "cloud_init_primary_group" {
  description = "primary group for the user on the linux system"
  type = string
  default = "vmware"
}

variable "cloud_init_groups" {
  description = "comma separated list of groups for the user on the linux system"
  type = string
  default = "wheel"
}

variable "cloud_init_user_shell" {
  description = "user shell"
  type = string
  default = "/bin/bash"
}

#
# VM
#
variable "vm_count" {
  description = "Number of VMs"
  type = number
  default = 1

  validation {
    condition = var.vm_count >= 0
    error_message = "Variable vm_count cannot be negative."
  }
}

variable "vm_name_prefix" {
  description = "vm name prefix"
  type = string
  default = "kafka"
}

variable "vm_firmware" {
  description = "firmware for the vm efi/bios"
  type = string
  default = "efi"

  validation {
    condition = var.vm_firmware == "bios" || var.vm_firmware == "efi"
    error_message = "Variable vm_firmware must be 'bios' or 'efi'."
  }
}

variable "vm_hardware_version" {
  description = "vSphere hardware hardware version"
  type = string
  default = 19

  validation {
    condition = var.vm_hardware_version >= 3 && var.vm_hardware_version <= 20
    error_message = "Variable vm_hardware_version must be between 3 and 20."
  }
}

variable "vm_cpu_count" {
  description = "Number of CPUs"
  type = number
  default = 4

  validation {
    condition = var.vm_cpu_count >= 1
    error_message = "Variable vm_cpu_count must be 1 or more."
  }
}

variable "vm_mem_size_mb" {
  description = "Size of memory in MiB"
  type = number
  default = 4096

  validation {
    condition = var.vm_mem_size_mb >= 512
    error_message = "Variable vm_mem_size_mb must be at least 512."
  }
}

variable "vm_disk_os_size_gb" {
  description = "Size of the OS disk in GiB"
  type = number
  default = 60

  validation {
    condition = var.vm_disk_os_size_gb >= 16
    error_message = "Variable vm_disk_os_size_gb must be at least 16."
  }
}

variable "vm_disk_data_count" {
  description = "Number of data disks"
  type = number
  default = 0

  validation {
    condition = var.vm_disk_data_count >= 0
    error_message = "Variable vm_disk_data_count must 0 or more."
  }
}

variable "vm_disk_data_size_gb" {
  description = "Size of the data disk(s) in GiB"
  type = number
  default = 0

  validation {
    condition = var.vm_disk_data_size_gb >= 10
    error_message = "Variable vm_disk_data_size_gb must be at least 10."
  }
}

variable "vm_network_ipv4_ips" {
  type = list(list(object({
      ipv4_address = string
      ipv4_netmask = string
    })))
}

variable "vm_network_ipv4_gateway" {
  description = "ipv4 gateway"
  type = string
}

variable "vm_network_ipv4_dns_servers" {
  description = "DNS ip list"
  type = list(string)
}

variable "vm_network_domain" {
  description = "Domain name"
  type = string
}
