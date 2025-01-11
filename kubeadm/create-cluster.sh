#!/bin/bash
#set -x

# 설정 가져오기
source configure.sh

# 설치 파일, SSH키, 복사 후 마스터 노드 설치 수행
for (( c=0 ; c < number_of_nodes; c++)); 
do
  # 설치 파일 복사
  echo "====== COPYING INSTALL FILES ======"
  eval "$(echo "scp -q -i ${ssh_key} -r artifacts/kubeadm root@${node_ip[$c]}:/root")"
  eval "$(echo "scp -q -i ${ssh_key} ${ssh_key} root@${node_ip[$c]}:/root/.ssh/")"
  eval "$(echo "ssh -i ${ssh_key} root@${node_ip[$c]} chmod +x kubeadm/scripts/*.sh")"

  # 컨테이너디, Kubelet 설치
  echo "====== INSTALLING CONTAIND, KUBELETS ======"
  eval "$(echo "ssh -i ${ssh_key} root@${node_ip[$c]} kubeadm/scripts/prepare.sh")"

  # 마스터 노드 설치
  if [[ "${node_role[$c]}" == "master" ]]
  then
    # 노드 역할이 master 인 경우 master_init.sh 실행
    echo "${node_name[$c]} :" "master"
    echo "====== SETTING MASTER NODE UP ======"
    eval "$(echo "ssh -i ${ssh_key} root@${node_ip[$c]} kubeadm/scripts/master_init.sh")"
  fi
done

# 마스터 멤버 노드, 워커 노드 설치 수행
for (( c=0 ; c < number_of_nodes; c++)); 
do
  if [[ "${node_role[$c]}" == "master-member" ]]
  then
    # 노드 역할이 master_member인 경우 master_member.sh 실행
    echo "${node_name[$c]} :" "master-member"
    echo "====== SETTING MASTER MEMBER UP ======"
    eval "$(echo "ssh -i ${ssh_key} root@${node_ip[$c]} kubeadm/scripts/master_member.sh")"
  elif [[ "${node_role[$c]}" == "worker" ]]
  then
    # 노드 역할이 worker 인 경우 worker.sh 실행
    echo "${node_name[$c]} :" "worker"
    echo "====== SETTING WORKER UP ======"
    eval "$(echo "ssh -i ${ssh_key} root@${node_ip[$c]} kubeadm/scripts/worker.sh")"
  else
    echo "${node_name[$c]} :" "master"
    echo "====== CHECKING MASTER NODE  ======"
  fi
done