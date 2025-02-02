#!/bin/sh

mkdir -p /etc/rancher/rke2
cp /root/rke2/scripts/config.yaml /etc/rancher/rke2/
sed -i '1iserver: https://192.168.122.229:9345' /etc/rancher/rke2/config.yaml

curl -sfL https://get.rke2.io |  INSTALL_RKE2_VERSION=v1.31.0+rke2r1 INSTALL_RKE2_TYPE=agent sh -
systemctl enable rke2-agent.service --now
