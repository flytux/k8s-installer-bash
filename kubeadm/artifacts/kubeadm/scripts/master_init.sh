# 01 init cluster 
modprobe br_netfilter
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

PATH=/usr/local/bin:/root/.vscode-server/cli/servers/Stable-fabdb6a30b49f79a7aba0f2ad9df9b399473380f/server/bin/remote-cli:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
kubeadm init --pod-network-cidr=10.244.0.0/16 --upload-certs --control-plane-endpoint=m1.local:6443 --kubernetes-version v1.31.0 | sed -e '/kubeadm join/,/--certificate-key/!d' | head -n 3 > join_cmd
# 02 copy kubeconfig
mkdir -p /root/.kube
cp -ru /etc/kubernetes/admin.conf /root/.kube/config
chown 0:0 /root/.kube/config

# 03 install cni
kubectl taint nodes m1.local node-role.kubernetes.io/control-plane:NoSchedule-

#helm repo add cilium https://helm.cilium.io/
helm upgrade -i cilium kubeadm/kubernetes/charts/cilium-1.16.5.tgz -f /root/kubeadm/cilium/values.yaml -n kube-system


#helm repo add traefik https://helm.traefik.io/traefik --force-update
helm upgrade -i traefik kubeadm/kubernetes/charts/traefik-33.2.1.tgz -n kube-system --set ingressRoute.dashboard.enabled=true

sleep 30

kubectl apply -f /root/kubeadm/cilium/announce-ip-pool.yaml
