# 01 init cluster 
modprobe br_netfilter
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

PATH=/usr/local/bin:$PATH
kubeadm init --pod-network-cidr=${pod_cidr} --upload-certs --control-plane-endpoint=${master_hostname}:6443 --kubernetes-version ${kube_version} | \
sed -e '/kubeadm join/,/--certificate-key/!d' | head -n 3 > join_cmd
# 02 copy kubeconfig
mkdir -p $HOME/.kube
cp -ru /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

# 03 install cni
kubectl taint nodes ${master_hostname} node-role.kubernetes.io/control-plane:NoSchedule-

#helm repo add cilium https://helm.cilium.io/
helm upgrade -i cilium kubeadm/kubernetes/charts/cilium-1.16.5.tgz -f $HOME/kubeadm/cilium/values.yaml -n kube-system


#helm repo add traefik https://helm.traefik.io/traefik --force-update
helm upgrade -i traefik kubeadm/kubernetes/charts/traefik-33.2.1.tgz -n kube-system --set ingressRoute.dashboard.enabled=true

sleep 30

kubectl apply -f $HOME/kubeadm/cilium/announce-ip-pool.yaml
