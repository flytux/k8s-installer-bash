#!/bin/sh

swapoff -a                 
sed -e '/swap/ s/^#*/#/' -i /etc/fstab  

mkdir -p /etc/rancher/rke2
cp /root/rke2/scripts/config.yaml /etc/rancher/rke2/

# Install rke2
curl -sfL https://get.rke2.io |  INSTALL_RKE2_VERSION=v1.31.0+rke2r1 sh -
systemctl enable rke2-server.service --now

# Install kubectl, helm, k9s
curl -LO https://dl.k8s.io/release/v1.32.0/bin/linux/amd64/kubectl && chmod +x kubectl &&  mv kubectl /usr/local/bin
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -s -L https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_Linux_amd64.tar.gz | tar xvzf - -C /usr/local/bin

# Copy kubeconfig rke2
mkdir -p /root/.kube && cp /etc/rancher/rke2/rke2.yaml /root/.kube/config

# Install Cilium
helm repo add cilium https://helm.cilium.io/
helm upgrade -i --wait cilium cilium/cilium --version 1.16.5 -f /root/rke2/cilium/values.yaml -n kube-system

kubectl apply -f /root/rke2/cilium/announce-ip-pool.yaml
