#!/bin/bash

# https://cloud-images.ubuntu.com/daily/server/jammy/current/jammy-server-cloudimg-amd64.img

declare -a nodes=( $(cat node-list) )

for node in "${nodes[@]}"
do
 echo "node name:" $node
 sudo virt-install --name $node --memory 10240 --vcpus 4 \
   --disk=size=100,backing_store=/var/lib/libvirt/images/jammy-server-cloudimg-amd64.img \
   --cloud-init user-data=./cloud-init/cloud-init-$node.yaml,disable=on --network bridge=virbr0 --osinfo=ubuntu22.04 --noautoconsole
done
