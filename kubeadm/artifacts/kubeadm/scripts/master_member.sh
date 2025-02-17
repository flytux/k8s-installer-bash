# 01 init cluster
modprobe br_netfilter
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.d/99-sysctl.conf
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
sysctl --system

chmod 400 /root/.ssh/id_rsa

until [ $(ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no 192.168.122.157 -- cat join_cmd | wc -l) != 0 ];
do
        echo Wait Master Node Init..
	sleep 10
done
        ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no 192.168.122.157 -- cat join_cmd | sh -

# 02 copy kubeconfig
mkdir -p /root/.kube
cp -ru /etc/kubernetes/admin.conf /root/.kube/config
chown 0:0 /root/.kube/config
