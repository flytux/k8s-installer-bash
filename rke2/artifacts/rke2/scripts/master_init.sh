#!/bin/sh

swapoff -a                 
sed -e '/swap/ s/^#*/#/' -i /etc/fstab  

mkdir -p /etc/rancher/rke2
cp /root/rke2/scripts/config.yaml /etc/rancher/rke2/

# check role
echo master > role

# Install rke2
#curl -sfL https://get.rke2.io |  INSTALL_RKE2_VERSION=v1.33.1+rke2r1 sh -

# Install rpms
rpm -Uvh /root/rke2/rpms/*.rpm

INSTALL_RKE2_ARTIFACT_PATH=/root/rke2/rke2/bin/v1.33.1 sh /root/rke2/rke2/bin/v1.33.1/install.sh

systemctl enable rke2-server.service --now

# Install kubectl, helm, k9s
#curl -LO https://dl.k8s.io/release/v1.33.3/bin/linux/amd64/kubectl && chmod +x kubectl &&  mv kubectl /usr/local/bin
#curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
#curl -s -L https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_Linux_amd64.tar.gz | tar xvzf - -C /usr/local/bin
cp rke2/kubernetes/* /usr/local/bin
chmod +x /usr/local/bin/*

mkdir -p /etc/nerdctl && cp rke2/kubernetes/nerdctl.toml /etc/nerdctl

# Copy kubeconfig rke2
mkdir -p /root/.kube && cp /etc/rancher/rke2/rke2.yaml /root/.kube/config

# Install Cilium
#helm repo add cilium https://helm.cilium.io/
helm upgrade -i --wait cilium -f /root/rke2/cilium/values.yaml  /root/rke2/cilium/cilium-1.16.5.tgz -n kube-system

kubectl apply -f /root/rke2/cilium/announce-ip-pool.yaml
