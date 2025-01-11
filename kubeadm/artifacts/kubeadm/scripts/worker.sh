# 01 init node
modprobe br_netfilter
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

chmod 400 /root/.ssh/id_rsa

# Rocky linux 
#dnf install -y socat conntrack

until [ 1 != 0 ];
do
        echo Wait Master Node Init..
	sleep 10
done
        ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no 192.168.122.187 -- kubeadm token create --print-join-command | sh -

mkdir -p /root/.kube
ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no 192.168.122.187 -- cat /etc/kubernetes/admin.conf > /root/.kube/config
sed -i s/127.0.0.1/{master_ip}/g /root/.kube/config
