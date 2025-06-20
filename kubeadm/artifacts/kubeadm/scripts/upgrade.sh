
NEW_VERSION=v1.32.1
MASTER_IP=192.168.122.26
HOST_IP=$(hostname -I | awk '{print $1}')
OLD_VERSION=$(/usr/local/bin/kubeadm version | grep -oE 'v([1-9]|\.)+')

echo ===== CHECK KUBEADM PLAN =====
mv /usr/local/bin/kubeadm /usr/local/bin/kubeadm-$OLD_VERSION
cp kubeadm/kubernetes/bin/$NEW_VERSION/kubeadm /usr/local/bin/kubeadm && chmod +x /usr/local/bin/kubeadm

kubeadm upgrade plan

if [ "$HOST_IP" = "$MASTER_IP" ]
  then
    echo ===== UPGRADE MASTER INIT NODE ===
    kubeadm upgrade apply $NEW_VERSION -y
  else
    mkdir -p $HOME/.kube
    ssh -o StrictHostKeyChecking=no $MASTER_IP -- cat /etc/kubernetes/admin.conf > $HOME/.kube/config
    sed -i s/127.0.0.1/$MASTER_IP/g $HOME/.kube/config

    echo ===== DRAIN NODE =====
    while ! kubectl drain $(hostname) --ignore-daemonsets --delete-emptydir-data; do :; done

    echo ===== UPGRADE NODE =====
    kubeadm upgrade node 

fi

echo ===== STOP KUBELET.SERVICE =====
systemctl stop kubelet.service

echo ===== COPY NEW KUBENET =====
mv /usr/local/bin/kubelet /usr/local/bin/kubelet-$OLD_VERSION
cp kubeadm/kubernetes/bin/$NEW_VERSION/kubelet /usr/local/bin/kubelet && chmod +x /usr/local/bin/kubelet

echo ===== RESTART KUBELET.SERVICE =====
systemctl daemon-reload
systemctl restart kubelet.service

echo ===== RESTART CONDAINERD.SERVICE =====
systemctl restart containerd.service


echo ===== UNCORDON NODE =====
while ! kubectl uncordon $(hostname); do :; done
