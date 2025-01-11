#!/bin/bash

# https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2

declare -a nodes=( $(cat node-list) )

for node in "${nodes[@]}"
do
 echo "node name:" $node
 sudo virt-install --name $node --memory 2048 --vcpus 4 \
   --disk=size=100,backing_store=/var/lib/libvirt/images/Rocky-9-GenericCloud.latest.x86_64.qcow2 \
   --cloud-init user-data=./cloud-init/cloud-init-$node.yaml,disable=on --network bridge=virbr0 --osinfo=rocky9 --noautoconsole
done
