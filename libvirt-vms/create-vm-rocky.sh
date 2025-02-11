#!/bin/bash

# https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2

source cloud-init.sh

for node in "${nodes[@]}"
do
 echo "node name:" $node
 sudo virt-install --name $node --memory 10240 --vcpus 6 \
   --disk=size=100,backing_store=/var/lib/libvirt/images/Rocky-9.4-GenericCloud-Base.x86_64.qcow2 \
   --cloud-init user-data=./cloud-init/cloud-init-$node.yaml,disable=on --network bridge=virbr0 --osinfo=rocky9 --noautoconsole
done
