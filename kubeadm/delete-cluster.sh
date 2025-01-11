#!/bin/bash
#set -x

source configure.sh

for (( c=0 ; c < number_of_nodes; c++)); 
do

  # Kubeadm reset 스크립트 실행
  echo "====== DELETE CLUSTERS ======"
  ssh -i ${ssh_key} root@${node_ip[$c]} kubeadm/scripts/reset.sh

done

