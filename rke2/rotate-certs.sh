#!/bin/bash
#set -x

source configure.sh

for (( c=0 ; c < number_of_nodes; c++)); 
do

  # rke2 rotate 스크립트 실행
  echo "====== RKE2 ROTATE CERTS ======"
  eval "$(echo "scp -q -i ${ssh_key} -r artifacts/rke2 root@${node_ip[$c]}:/root")"
  eval "$(echo "ssh -i ${ssh_key} root@${node_ip[$c]} bash rke2/scripts/rotate_certs.sh")"

done
