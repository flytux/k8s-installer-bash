#!/bin/bash
set -x
MASTER_IP=192.168.222.180
MASTER_NAME=node-02.local

HOST_IP=$(hostname -I | awk '{print $1}')
HOST_NAME=$(hostname)

BACKUP_LOCATION=/root/etcd-backup

INITIAL_CLUSTER=node-02.local=https://192.168.222.180:2380

export ETCDCTL_API=3
export ETCDCTL_ENDPOINTS=https://${HOST_IP}:2379
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt

LATEST_BACKUP=$(ls -t ${BACKUP_LOCATION} | grep etcd | head -1)

mv /etc/kubernetes/manifests /etc/kubernetes/manifests-backup

yes | rm -rf /var/lib/etcd

etcdctl snapshot restore ${BACKUP_LOCATION}/${LATEST_BACKUP} --name=${HOST_NAME} --initial-advertise-peer-urls=https://${HOST_IP}:2380 --initial-cluster-token=etcd-cluster-0 --initial-cluster=${INITIAL_CLUSTER} --data-dir=/var/lib/etcd --skip-hash-check=true

mv /etc/kubernetes/manifests-backup /etc/kubernetes/manifests
