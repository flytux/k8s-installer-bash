#!/bin/bash
#set -x

file="./node-list.yaml"

# 설치 YAML 읽어서 변수 할당
number_of_nodes=$(yq -r ".nodes | length" $file)
ssh_key=$(yq -r ".ssh_key" $file)
master_ip=$(yq -r ".master_ip" $file)
master_hostname=$(yq -r ".master_hostname" $file)
master_ip=$(yq -r ".master_ip" $file)
kube_version=$(yq -r ".kube_version" $file)
pod_cidr=$(yq -r ".pod_cidr" $file)

echo "==============================================================="
echo "number of nodes: " $number_of_nodes
echo "ssh key file: " $ssh_key
echo "master ip: " $master_ip
echo $master_hostname
echo $master_ip
echo $kube_version
echo "==============================================================="

# 노드 정보 읽어서 변수에 할당
for (( c=0; c < $number_of_nodes; c++))
do 
  node_name[$c]=$(yq -r ".nodes[$c].name" $file)
  node_ip[$c]=$(yq -r ".nodes[$c].ip" $file)
  node_role[$c]=$(yq -r ".nodes[$c].role" $file)

  echo "==============================================================="
  echo "node name $c :" ${node_name[$c]}
  echo "node ip $c :" ${node_ip[$c]}
  echo "node role $c :" ${node_role[$c]}
  echo "==============================================================="
done

# 기존 설치 스크립트 삭제
rm -rf artifacts/kubeadm/scripts/*.sh

# 설치 스크립트를 템플릿에서 생성
prepare_str=$(cat artifacts/kubeadm/scripts/prepare.tpl)
eval "echo \"${prepare_str}\"" > artifacts/kubeadm/scripts/prepare.sh

# master_init.sh 스크립트 생성
master_init_str=$(cat artifacts/kubeadm/scripts/master_init.tpl)
eval "echo \"${master_init_str}\"" > artifacts/kubeadm/scripts/master_init.sh

# master_member.sh 스크립트 생성
master_member_str=$(cat artifacts/kubeadm/scripts/master_member.tpl)
eval "echo \"${master_member_str}\"" > artifacts/kubeadm/scripts/master_member.sh

# worker.sh 스크립트 생성
worker_str=$(cat artifacts/kubeadm/scripts/worker.tpl)
eval "echo \"${worker_str}\"" > artifacts/kubeadm/scripts/worker.sh

# reset.sh 스크립트 생성
reset_str=$(cat artifacts/kubeadm/scripts/reset.tpl)
eval "echo \"${reset_str}\"" > artifacts/kubeadm/scripts/reset.sh
