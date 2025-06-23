#!/bin/bash
#set -x

yaml_file="./node-list.yaml"

# 설치 YAML 읽어서 변수 할당
number_of_nodes=$(yq -r ".nodes | length" $yaml_file)
ssh_key=$(yq -r ".ssh_key" $yaml_file)
master_ip=$(yq -r ".master_ip" $yaml_file)
master_hostname=$(yq -r ".master_hostname" $yaml_file)
master_node_name=$(yq -r ".master_node_name" $yaml_file)
backup_location=$(yq -r ".backup_location" $yaml_file)
master_ip=$(yq -r ".master_ip" $yaml_file)
kube_version=$(yq -r ".kube_version" $yaml_file)
kube_upgrade_version=$(yq -r ".kube_upgrade_version" $yaml_file)
pod_cidr=$(yq -r ".pod_cidr" $yaml_file)

echo "==============================================================="
echo "number of nodes: " $number_of_nodes
echo "ssh key YAML_FILE: " $ssh_key
echo "master ip: " $master_ip
echo "master hostname: " $master_hostname $master_node_name
echo "master ip: " $master_ip
echo "kube version: " $kube_version
echo "kube upgrade version: " $kube_upgrade_version
echo "==============================================================="

# 노드 정보 읽어서 변수에 할당
for (( c=0; c < $number_of_nodes; c++))
do 
  node_name[$c]=$(yq -r ".nodes[$c].name" $yaml_file)
  node_ip[$c]=$(yq -r ".nodes[$c].ip" $yaml_file)
  node_role[$c]=$(yq -r ".nodes[$c].role" $yaml_file)

  echo "==============================================================="
  echo "node name $c :" ${node_name[$c]}
  echo "node ip $c :" ${node_ip[$c]}
  echo "node role $c :" ${node_role[$c]}
  echo "==============================================================="

done

# yq를 사용해 YAML 파일 파싱
# 예시 배열
initial_cluster=""
is_cluster_member=false

for ((i=0; i<${#node_name[@]}; i++)); do
  n_name=${node_name[$i]}
  n_ip=${node_ip[$i]}
  n_role=${node_role[$i]}

  # 디버깅 출력
  echo "Processing: $n_name $n_ip $n_role"

  # 마스터 계열 노드만 포함
  if [[ "$n_role" == master* ]]; then
    entry="${n_name}=https://${n_ip}:2380"

    if [[ -z "$initial_cluster" ]]; then
      initial_cluster="$entry"
    else
      initial_cluster="${initial_cluster},$entry"
    fi

  fi
done

echo "initial_cluster = $initial_cluster"

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

# upgrade.sh 스크립트 생성
upgrade_str=$(cat artifacts/kubeadm/scripts/upgrade.tpl)
eval "echo \"${upgrade_str}\"" > artifacts/kubeadm/scripts/upgrade.sh

# reset.sh 스크립트 생성
reset_str=$(cat artifacts/kubeadm/scripts/reset.tpl)
eval "echo \"${reset_str}\"" > artifacts/kubeadm/scripts/reset.sh

# etcd-backup.sh, etcd-restore.sh 스크립트 생성
etcd_backup_str=$(cat artifacts/kubeadm/scripts/etcd_backup.tpl)
eval "echo \"${etcd_backup_str}\"" > artifacts/kubeadm/scripts/etcd_backup.sh

etcd_restore_str=$(cat artifacts/kubeadm/scripts/etcd_restore.tpl)
eval "echo \"${etcd_restore_str}\"" > artifacts/kubeadm/scripts/etcd_restore.sh
