# vCenter configurations
vcenter_server = "vc.vmware.com"
vcenter_user = "administrator@vsphere.local"
vcenter_password = "P@ssword123!"
vcenter_insecure_ssl = true

# vSphere configuration
vsphere_datacenter = "Datacenter"
vsphere_compute_cluster ="Cluster"
vsphere_datastore_name = "vsanDatastore"
vsphere_resource_pool_name = "test-rp"
vsphere_networks = [{name="VM Network", ovf_mapping="eth0"}, {name="VM Network 2", ovf_mapping="eth1"}]

# Content library
vsphere_content_library_name = "Automation Content Library"
vsphere_content_library_description = "A new source of content."
vsphere_content_library_item_name = "CentOS Stream 9"
vsphere_content_library_item_description = "CentOS Stream 9 Cloud Image prepared by Charles Lee"
vsphere_content_library_item_file_url =  "https://storage.googleapis.com/workload-automation/templates/centos-stream-9-cloudimg.ova"

# Cloud init
#cloud_init_username = "vmware"
#cloud_init_password = "P@ssword123!"
#cloud_init_primary_group = "vmware"
#cloud_init_groups = "wheel"
#cloud_init_user_shell = "/bin/bash"

# SSH
#rsa_public_key_file = "~/.ssh/id_rsa.pub"

# VM
vm_name_prefix = "test"
#vm_firmware = "efi"
#vm_hardware_version = 19
#vm_count = 1
#vm_cpu_count = 4
#vm_mem_size_mb = 8192
vm_disk_os_size_gb = 50
vm_disk_data_count = 2
vm_disk_data_size_gb = 100

# VM Networking
vm_network_ipv4_gateway = "192.168.1.1"
vm_network_ipv4_dns_servers = ["8.8.8.8","8.8.4.4"]
vm_network_domain = "vmware.com"
vm_network_ipv4_ips = [
  [
    {ipv4_address="192.168.1.215",ipv4_netmask="24"},
    {ipv4_address="192.168.2.215",ipv4_netmask="24"}
  ],
  [
    {ipv4_address="192.168.1.216",ipv4_netmask="24"},
    {ipv4_address="192.168.2.216",ipv4_netmask="24"}
  ],
  [
    {ipv4_address="192.168.1.217",ipv4_netmask="24"},
    {ipv4_address="192.168.2.217",ipv4_netmask="24"}
  ],
  [
    {ipv4_address="192.168.1.218",ipv4_netmask="24"},
    {ipv4_address="192.168.2.218",ipv4_netmask="24"}
  ],
  [
    {ipv4_address="192.168.1.219",ipv4_netmask="24"},
    {ipv4_address="192.168.2.219",ipv4_netmask="24"}
  ],
  [
    {ipv4_address="192.168.1.220",ipv4_netmask="24"},
    {ipv4_address="192.168.2.220",ipv4_netmask="24"}
  ]
]
