# 01 init cluster
modprobe br_netfilter
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.d/99-sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl --system

chmod 400 $HOME/.ssh/id_rsa

until [ $(echo "\$(ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no ${master_ip} -- cat join_cmd | wc -l)") != 0 ];
do
        echo "Wait Master Node Init.."
	sleep 10
done
        ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no ${master_ip} -- cat join_cmd | sh -

# 02 copy kubeconfig
mkdir -p $HOME/.kube
cp -ru /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
