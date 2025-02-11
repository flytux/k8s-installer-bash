#!/bin/bash
#set -x

file="./node-list.yaml"

# 설치 YAML 읽어서 변수 할당
number_of_nodes=$(yq -r ".nodes | length" $file)
ssh_key=$(yq -r ".ssh_key" $file)
master_ip=$(yq -r ".master_ip" $file)
master_hostname=$(yq -r ".master_hostname" $file)
rke2_version=$(yq -r ".rke2_version" $file)
upgrade_rke2_version=$(yq -r ".upgrade_rke2_version" $file)
pod_cidr=$(yq -r ".pod_cidr" $file)
token=$(yq -r ".token" $file)
tls_san=$(yq -r ".tls_san" $file)


echo "==============================================================="
echo "number of nodes: " $number_of_nodes
echo "ssh key file: " $ssh_key
echo "master ip: " $master_ip
echo "master_hostname: " $master_hostname
echo "installed rke2 version " $rke2_version
echo "upgrade rke2 version " $upgrade_rke2_version
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
rm -rf artifacts/rke2/scripts/*.sh

# 설치 스크립트를 템플릿에서 생성
config_str=$(cat artifacts/rke2/scripts/config.tpl)
eval "echo \"${config_str}\"" > artifacts/rke2/scripts/config.yaml

# master_init.sh 스크립트 생성
master_init_str=$(cat artifacts/rke2/scripts/master_init.tpl)
eval "echo \"${master_init_str}\"" > artifacts/rke2/scripts/master_init.sh

# master_member.sh 스크립트 생성
master_member_str=$(cat artifacts/rke2/scripts/master_member.tpl)
eval "echo \"${master_member_str}\"" > artifacts/rke2/scripts/master_member.sh

# worker.sh 스크립트 생성
worker_str=$(cat artifacts/rke2/scripts/worker.tpl)
eval "echo \"${worker_str}\"" > artifacts/rke2/scripts/worker.sh

# upgrade_master.sh 스크립트 생성
upgrade_master_str=$(cat artifacts/rke2/scripts/upgrade_master.tpl)
eval "echo \"${upgrade_master_str}\"" > artifacts/rke2/scripts/upgrade_master.sh

# upgrade_worker.sh 스크립트 생성
upgrade_worker_str=$(cat artifacts/rke2/scripts/upgrade_worker.tpl)
eval "echo \"${upgrade_worker_str}\"" > artifacts/rke2/scripts/upgrade_worker.sh

# reset.sh 스크립트 생성
reset_str=$(cat artifacts/rke2/scripts/reset.tpl)
eval "echo \"${reset_str}\"" > artifacts/rke2/scripts/reset.sh
