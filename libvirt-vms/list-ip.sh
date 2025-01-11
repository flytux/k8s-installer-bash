#!/bin/bash

# https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2

sudo virsh net-dhcp-leases --network default | grep $1
