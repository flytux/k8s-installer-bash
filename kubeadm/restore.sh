#!/bin/bash

# 입력 파일
YAML_FILE="node-list.yaml"
BACKUP_LOCATION="/backup"
LATEST_BACKUP="snapshot.db"

# 현재 노드 정보 (자동 또는 수동 설정)
HOST_NAME=$(hostname -f)
HOST_IP=$(hostname -I | awk '{print $1}')

# etcd 클러스터 구성 초기화
INITIAL_CLUSTER=""
IS_CLUSTER_MEMBER=false

# yq를 사용해 YAML 파일 파싱
mapfile -t NODE_LIST < <(yq e '.nodes[] | [.name, .ip, .role] | @tsv' "$YAML_FILE")

for NODE_ENTRY in "${NODE_LIST[@]}"; do
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
