#!/bin/sh

#set -x
#Add k8smaster IP
echo 192.168.122.51 k8s-master >> /etc/hosts
echo 192.168.122.198 node-02.local >> /etc/hosts

# Swap off
swapoff -a                 
sed -e '/swap/ s/^#*/#/' -i /etc/fstab  

if [ $(cat /etc/*release | grep -i ubuntu | wc -l) -ne 0 ]; 
then
  echo Ubuntu: Install containerd, socat, conntrack
  # dpkg -i kubeadm/packages/*.deb
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
  sudo apt-get update
  sudo apt-get install -y containerd.io

elif [ $(cat /etc/*release | grep -i -E "rocky|alma" | wc -l) -ne 0 ];
then 
  echo Rocky: Install containerd, socat, conntrack
  setenforce 0
  sed -i --follow-symlinks 's/SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
  dnf install -y dnf-utils
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  dnf install -y containerd.io socat conntrack iproute-tc iptables
  #rpm -Uvh kubeadm/packages/*.rpm --force
else
  echo ====== Try Ubuntu or Rocky ======
fi

# Config containerd
mkdir -p /etc/containerd
cp kubeadm/packages/config.toml /etc/containerd/

systemctl restart containerd
systemctl enable containerd 

mkdir -p /etc/nerdctl
cp kubeadm/kubernetes/config/nerdctl.toml /etc/nerdctl/nerdctl.toml

# Copy network binaries
cp -r kubeadm/kubernetes/bin/* /usr/local/bin

# Copy kubernetes binaries
cp -r kubeadm/kubernetes/bin/v1.31.0/* /usr/local/bin

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
