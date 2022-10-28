## gcloud commands to create 3 vms for the cluster
```bash
gcloud compute instances create master worker-1 worker-2 --create-disk=auto-delete=yes,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20211115 --zone us-central1-a --machine-type=e2-medium
```

## Install Packages ( The following steps must be performed on all three nodes)

```bash
# Create configuration file for containerd:
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Load modules:

sudo modprobe overlay
sudo modprobe br_netfilter

### Set system configurations for Kubernetes networking:
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply new settings:
sudo sysctl --system

# Install containerd:
sudo apt-get update && sudo apt-get install -y containerd

# Create default configuration file for containerd
sudo mkdir -p /etc/containerd

# Generate default containerd configuration and save to the newly created default file
sudo containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd to ensure new configuration file usage
sudo systemctl restart containerd

# Verify that containerd is running:
# sudo systemctl status containerd

# Disable swap:
sudo swapoff -a

# Install dependency packages:
sudo apt-get update && sudo apt-get install -y apt-transport-https curl

# Download and add GPG key:
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -


#Add Kubernetes to repository list:
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Update package listings:
sudo apt-get update

# Install Kubernetes packages (Note: If you get a dpkg lock message, just wait a minute or two before trying the command again):
sudo apt-get install -y kubelet=1.24.0-00 kubeadm=1.24.0-00 kubectl=1.24.0-00

# Turn off automatic updates:
sudo apt-mark hold kubelet kubeadm kubectl
```

## Initialize the Cluster (Note: This is only performed on the Control Plane Node):
```bash
# Initialize the Kubernetes cluster on the control plane node using kubeadm 
sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.24.0

# Set kubectl access
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Test access to cluster:
kubectl get nodes
```

## Join the Worker Nodes to the Cluster
```bash
# In the control plane node, create the token and copy the kubeadm join command (NOTE:The join command can also be found in the output from kubeadm init command):
kubeadm token create --print-join-command

# In both worker nodes, paste the kubeadm join command to join the cluster. Use sudo to run it as root:
sudo kubeadm join ...

# In the control plane node, view cluster status (Note: You may have to wait a few moments to allow all nodes to become ready):
kubectl get nodes
```


## Install the Calico Network Add-On
```bash
# On the control plane node, install Calico Networking:
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Check status of the control plane node:
kubectl get nodes

```
