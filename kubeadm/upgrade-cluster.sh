#!/bin/bash
#set -x

# 설정 가져오기
source configure.sh

(cd artifacts/kubeadm/kubernetes/bin/${kube_upgrade_version} && bash download_kubernetes.sh)

# 설치 파일, SSH키, 복사 후 업그레이드 수행
for (( c=0 ; c < number_of_nodes; c++)); 
do
  # 설치 파일 복사
  echo "====== COPYING INSTALL FILES ======"
  eval "$(echo "scp -q -i ${ssh_key} -r artifacts/kubeadm root@${node_ip[$c]}:/root")"
  eval "$(echo "scp -q -i ${ssh_key} ${ssh_key} root@${node_ip[$c]}:/root/.ssh/")"
  eval "$(echo "ssh -i ${ssh_key} root@${node_ip[$c]} chmod +x kubeadm/scripts/*.sh")"

  # 컨테이너디, Kubelet 설치
  echo "====== INSTALLING CONTAIND, KUBELETS ======"
  eval "$(echo "ssh -i ${ssh_key} root@${node_ip[$c]} kubeadm/scripts/upgrade.sh")"
done

