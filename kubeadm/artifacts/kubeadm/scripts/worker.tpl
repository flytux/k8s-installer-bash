# 01 init node
modprobe br_netfilter
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.d/99-sysctl.conf
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl --system

chmod 400 $HOME/.ssh/id_rsa

# Rocky linux 
#dnf install -y socat conntrack

until [ $(echo "\$(ssh -i /root/.ssh/id_rsa -o StrictHostKeyChecking=no ${master_ip} -- cat join_cmd)" | wc -l) != 0 ];
do
        echo "Wait Master Node Init.."
	sleep 10
done
        ssh -i $HOME/.ssh/id_rsa -o StrictHostKeyChecking=no ${master_ip} -- kubeadm token create --print-join-command | sh -

mkdir -p $HOME/.kube
ssh -i $HOME/.ssh/id_rsa -o StrictHostKeyChecking=no ${master_ip} -- cat /etc/kubernetes/admin.conf > $HOME/.kube/config
sed -i "s/127\.0\.0\.1/{master_ip}/g" $HOME/.kube/config
