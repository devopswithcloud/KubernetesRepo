
# Unhold the current version of kubeadm , kubelet and kubectl
apt-mark unhold kubeadm kubelet kubectl

# Determine which version to upgrade to
apt-cache madison kubeadm

# Upgrade kubeadm to the desired version
apt-get update && apt-get install -y kubeadm=1.29.3-1.1 && apt-mark hold kubeadm

# Get the version for upgrade
kubeadm upgrade plan

# Upgrade the cluster to a specific version
kubeadm upgrade apply v1.29.3

# upgrade kubelet and kubectl 
apt-get install -y kubelet=1.29.3-1.1 kubectl=1.29.3-1.1 && apt-mark hold kubelet kubectl

# Drain the master node
kubectl drain master --ignore-daemonsets --force


# Restart kubelet
sudo systemctl restart kubelet
sudo systemctl daemon-reload


# Uncordon the master node
kubectl uncordon master
