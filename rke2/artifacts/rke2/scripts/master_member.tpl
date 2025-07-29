#!/bin/sh

echo "master-member" > role

mkdir -p /etc/rancher/rke2
cp $HOME/rke2/scripts/config.yaml /etc/rancher/rke2/
sed -i '1iserver: https://${master_ip}:9345' /etc/rancher/rke2/config.yaml

INSTALL_RKE2_VERSION=${rke2_version}+rke2r1 sh /root/rke2/rke2/bin/${rke2_version}/install.sh
systemctl enable rke2-server.service --now

mkdir -p $HOME/.kube && cp /etc/rancher/rke2/rke2.yaml $HOME/.kube/config