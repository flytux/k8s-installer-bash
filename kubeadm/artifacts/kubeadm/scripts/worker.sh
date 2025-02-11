# 01 init node
modprobe br_netfilter
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.d/99-sysctl.conf
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
sysctl --system

chmod 400 /root/.ssh/id_rsa

# Rocky linux 
#dnf install -y socat conntrack

until [ 1 != 0 ];
do
        echo Wait Master Node Init..
	sleep 10
done
        ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no 192.168.122.157 -- kubeadm token create --print-join-command | sh -

mkdir -p /root/.kube
ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no 192.168.122.157 -- cat /etc/kubernetes/admin.conf > /root/.kube/config
sed -i s/127.0.0.1/{master_ip}/g /root/.kube/config
