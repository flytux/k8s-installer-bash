#!/bin/sh

swapoff -a                 
sed -e '/swap/ s/^#*/#/' -i /etc/fstab  

mkdir -p /etc/rancher/rke2
cp $HOME/rke2/scripts/config.yaml /etc/rancher/rke2/

# check role
echo "master" > role

# Install rke2
curl -sfL https://get.rke2.io |  INSTALL_RKE2_VERSION=${rke2_version}+rke2r1 sh -
systemctl enable rke2-server.service --now

# Install kubectl, helm, k9s
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl &&  mv kubectl /usr/local/bin
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -s -L https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_Linux_amd64.tar.gz | tar xvzf - -C /usr/local/bin

# Copy kubeconfig rke2
mkdir -p $HOME/.kube && cp /etc/rancher/rke2/rke2.yaml $HOME/.kube/config

# Install Cilium
helm repo add cilium https://helm.cilium.io/
helm upgrade -i --wait cilium cilium/cilium --version 1.16.5 -f $HOME/rke2/cilium/values.yaml -n kube-system

kubectl apply -f $HOME/rke2/cilium/announce-ip-pool.yaml
