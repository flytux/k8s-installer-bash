#!/bin/bash

# read node-list for creating vms
declare -a nodes=( $(cat node-list) )

# set ssh_key to vms
ssh_key="$(cat ~/.ssh/id_rsa.pub)"

# create cloud-init yaml
for node in "${nodes[@]}"
do

# delete existing cloud-init file
file="./cloud-init/cloud-init-$node.yaml"
[ -f $file ] && rm $file

# create cloud-init file
cat > $file << EOF 

#cloud-config
hostname: $node
fqdn: $node.local

users:
  # whatever username you like
  - name: jaehoon
    # so our user can just sudo without any password
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    # content from $HOME/.ssh/id_rsa.pub on your host system
    ssh_authorized_keys:
      - $ssh_key
  - name: root
    ssh_authorized_keys:
      - $ssh_key
ssh_pwauth: true
disable_root: false
chpasswd:
  list: |
    jaehoon:1
    root:root
  expire: False
EOF
done
