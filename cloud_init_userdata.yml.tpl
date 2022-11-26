#cloud-config
# https://cloudinit.readthedocs.io/en/latest/topics/modules.html
ssh_pwauth: true
users:
  - name: ${username}
    primary_group: ${primary_group}
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: ${groups}
    shell: ${shell}
    ssh_import_id: None
    lock_passwd: false
    passwd: ${password}
    ssh_authorized_keys:
      ${ssh_key_list}

%{ if data_disks_count > 0 }
runcmd:
%{ for i in range(0, data_disks_count) ~}
  - mkdir -p /data${i}
%{ endfor ~}

disk_setup:
%{ for i in range(0, data_disks_count) ~}
  /dev/sd${["b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"][i]}:
    table_type: 'gpt'
    layout: true
%{ endfor ~}

fs_setup:
%{ for i in range(0, data_disks_count) ~}
  - label: data${i}
    device: /dev/sd${["b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"][i]}
    filesystem: 'xfs'
    partition: 'auto'
%{ endfor ~}

mount_default_fields: [ None, None, "auto", "defaults,noatime,nofail", "0", "2" ]
mounts:
%{ for i in range(0, data_disks_count) ~}
  - [LABEL=data${i}, /data${i}]
%{ endfor ~}
%{ endif }
