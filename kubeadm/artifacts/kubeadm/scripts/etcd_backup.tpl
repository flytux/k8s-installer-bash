#!/bin/bash
set -x

HOST_IP=\$(hostname -I | awk '{print \$1}')
HOST_NAME=\$(hostname)

MASTER_NODE_NAME=${master_node_name}

if [[ "\$HOST_NAME" == "\$MASTER_NODE_NAME" ]]; then
  echo "[+] 이 노드는 마스터입니다. etcd 백업을 실행합니다."

BACKUP_LOCATION=${backup_location}

export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://\${HOST_IP}:2379
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt

mkdir -p \${BACKUP_LOCATION}

echo "===== ETCD MEMBERS ====="
etcdctl member list -w table

echo "===== CREATING ETCD SNAPSHOTS ====="
etcdctl snapshot save \${BACKUP_LOCATION}/etcd-`date +%Y%m%d_%H%M%S`

else
  echo "[-] 이 노드는 마스터가 아니므로 etcd 백업을 생략합니다."
fi
