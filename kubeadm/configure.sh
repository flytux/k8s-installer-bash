#!/bin/bash
#set -x

YAML_FILE="./node-list.yaml"

# 설치 YAML 읽어서 변수 할당
number_of_nodes=$(yq -r ".nodes | length" $YAML_FILE)
ssh_key=$(yq -r ".ssh_key" $YAML_FILE)
master_ip=$(yq -r ".master_ip" $YAML_FILE)
master_hostname=$(yq -r ".master_hostname" $YAML_FILE)
master_node_name=$(yq -r ".master_node_name" $YAML_FILE)
backup_location=$(yq -r ".backup_location" $YAML_FILE)
master_ip=$(yq -r ".master_ip" $YAML_FILE)
kube_version=$(yq -r ".kube_version" $YAML_FILE)
kube_upgrade_version=$(yq -r ".kube_upgrade_version" $YAML_FILE)
pod_cidr=$(yq -r ".pod_cidr" $YAML_FILE)

echo "==============================================================="
echo "number of nodes: " $NUMBER_OF_NODES
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
  node_name[$c]=$(yq -r ".nodes[$c].name" $YAML_FILE)
  node_ip[$c]=$(yq -r ".nodes[$c].ip" $YAML_FILE)
  node_role[$c]=$(yq -r ".nodes[$c].role" $YAML_FILE)

  echo "==============================================================="
  echo "node name $c :" ${node_name[$c]}
  echo "node ip $c :" ${node_ip[$c]}
  echo "node role $c :" ${node_role[$c]}
  echo "==============================================================="

done

# yq를 사용해 YAML 파일 파싱
mapfile -t NODE_LIST < <(yq e '.nodes[] | [.name, .ip, .role] | @tsv' "$YAML_FILE")

for NODE_ENTRY in "${NODE_LIST[@]}"; do 
  echo $NODE_ENTRY
  IFS=$'\t' read -r NODE_NAME NODE_IP NODE_ROLE <<< "$NODE_ENTRY"

  # 마스터 계열 노드만 initial-cluster 에 포함
  if [[ "$NODE_ROLE" == master* ]]; then
    ENTRY="${NODE_NAME}=https://${NODE_IP}:2380"

    if [[ -z "$INITIAL_CLUSTER" ]]; then
      INITIAL_CLUSTER="$ENTRY"
    else
      INITIAL_CLUSTER="${INITIAL_CLUSTER},$ENTRY"
    fi

    # 현재 노드가 클러스터 멤버인지 확인
    if [[ "$HOST_IP" == "$NODE_IP" || "$HOST_NAME" == "$NODE_NAME" ]]; then
      IS_CLUSTER_MEMBER=true
    fi
  fi
done
echo $INITIAL_CLUSTER

initial_cluster=$INITIAL_CLUSTER

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
