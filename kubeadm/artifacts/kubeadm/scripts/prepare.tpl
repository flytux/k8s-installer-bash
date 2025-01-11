#!/bin/sh

#set -x
#Add k8smaster IP
echo "${master_ip}    ${master_hostname}" >> /etc/hosts

# Swap off
swapoff -a                 
sed -e '/swap/ s/^#*/#/' -i /etc/fstab  

if [ $(echo "\$(cat /etc/*release | grep -i ubuntu | wc -l)" -ne 0) ]; 
then
  echo "Ubuntu: Install containerd, socat, conntrack"
  dpkg -i kubeadm/packages/*.deb
elif [ $(echo "\$(cat /etc/*release | grep -i rocky | wc -l)" -ne 0) ];
then 
  echo "Rocky: Install containerd, socat, conntrack"
  setenforce 0
  sed -i --follow-symlinks 's/SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
  #dnf install -y dnf-utils
  #dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  #dnf install -y containerd.io socat conntrack iproute-tc iptables-ebtables iptables
  rpm -Uvh kubeadm/packages/*.rpm --force
else
  echo "====== Try Ubuntu or Rocky ======"
fi

# Config containerd
mkdir -p /etc/containerd
cp kubeadm/packages/config.toml /etc/containerd/

mkdir -p /etc/nerdctl
cp kubeadm/kubernetes/config/nerdctl.toml /etc/nerdctl/nerdctl.toml

systemctl enable containerd --now

# Copy network binaries
cp kubeadm/kubernetes/bin/* /usr/local/bin

# Copy kubernetes binaries
cp kubeadm/kubernetes/bin/${kube_version}/* /usr/local/bin

chmod +x /usr/local/bin/*
cp -R kubeadm/cni /opt
chmod +x /opt/cni/bin/*

# Load kubeadm container images
#nerdctl load -i kubeadm/images/kubeadm.tar

# Configure and start kubelet
cp kubeadm/kubernetes/config/kubelet.service /etc/systemd/system
mkdir -p /etc/systemd/system/kubelet.service.d
\cp -f kubeadm/kubernetes/config/kubelet.service.d/10-kubeadm.conf /etc/systemd/system/kubelet.service.d

systemctl daemon-reload
systemctl enable kubelet --now
