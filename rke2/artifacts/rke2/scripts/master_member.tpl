#!/bin/sh

mkdir -p /etc/rancher/rke2
cp $HOME/rke2/scripts/config.yaml /etc/rancher/rke2/
sed -i '1iserver: https://${master_ip}:9345' /etc/rancher/rke2/config.yaml

curl -sfL https://get.rke2.io |  INSTALL_RKE2_VERSION=${rke2_version}+rke2r1 sh -
systemctl enable rke2-server.service --now
