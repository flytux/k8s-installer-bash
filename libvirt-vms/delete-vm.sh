#!/bin/bash

declare -a nodes=( $(cat node-list) )

# delete vms
for node in "${nodes[@]}"
do 
  sudo virsh destroy --domain $node && sudo virsh undefine --domain $node --remove-all-storage
done
