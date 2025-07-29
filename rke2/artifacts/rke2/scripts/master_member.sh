#!/bin/sh

echo master-member > role

mkdir -p /etc/rancher/rke2
cp /root/rke2/scripts/config.yaml /etc/rancher/rke2/
sed -i '1iserver: https://192.168.122.2:9345' /etc/rancher/rke2/config.yaml

INSTALL_RKE2_VERSION=v1.33.1+rke2r1 sh /root/rke2/rke2/bin/v1.33.1/install.sh
systemctl enable rke2-server.service --now

mkdir -p /root/.kube && cp /etc/rancher/rke2/rke2.yaml /root/.kube/config
