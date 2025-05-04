### gcloud commands to create 3 vms for the cluster
```bash
gcloud compute instances create master worker-1 worker-2 --create-disk=auto-delete=yes,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20211115 --zone us-central1-a --machine-type=e2-medium
```


### To Create a User in Ubuntu follow the below steps: (`Both master and worker`)
```bash
$ adduser username
#Example
adduser siva

#Add the new user to the sudo group 
usermod -aG sudo username
#Example
usermod -aG sudo siva

Switch to newly created user:
su - username

#How to Enable SSH Password Authentication
#To enable SSH password authentication, you must SSH in as root to edit this file:
/etc/ssh/sshd_config

PasswordAuthentication yes

sudo service ssh restart

```

### Install Docker on all nodes (`Both master and worker`)

[Installing Docker on ubuntu](https://docs.docker.com/engine/install/ubuntu/)
```bash
# Set up the repository
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y


# Add Docker’s official GPG key:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Use the following command to set up the repository:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update


# To install the latest version, run:
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y


# To install specific version , do refer documentation

sudo apt-mark hold docker-ce
sudo usermod -aG docker username
sudo docker version
rm /etc/containerd/config.toml
systemctl restart containerd

```

### On all nodes, install kubeadm, kubelet, and kubectl. (`Both master and worker`)
[Refer Here for Official documentation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
```bash
# Update the apt package index and install packages needed to use the Kubernetes apt repository:
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Download the Google Cloud public signing key:
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository:
#echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

# If we get errors like GPG error, execute the following command
# curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Update apt package index, install kubelet, kubeadm and kubectl with a specific version, and pin their version:
sudo apt-get update
sudo apt-get install -y kubelet=1.27.1-00 kubeadm=1.27.1-00 kubectl=1.27.1-00
#sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### On the Kube master server (` Master Only `)
```bash
# Configure cgroup driver used by kubelet on control-plane.(Only on master node)
	sudo docker info | grep -i cgroup

echo "Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=cgroupfs"" >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl restart kubelet

systemctl daemon-reload



# Initialising the control-plane node run the below command on the (master node)
sudo kubeadm init

# If we get error wrt container runtime not running , execute the below commands

rm /etc/containerd/config.toml
systemctl restart containerd
```
```


#Set up local kubeconfig:
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# If you need to generate a new tokem use the below command (Optional Not required , if you have the above token generated)
    sudo kubeadm token create --print-join-command
```

### Join the Worker nodes (`Only on Worker Nodes`)
```bash
Execute the command that is been generated as the output of the previous command, where we got the token generated. 
It will be similar to the below command

sudo kubeadm join 10.18.0.30:6443 --token 06fdx2qa.v2jxfdfdflapu54gi3s41 --discovery-token-ca-cert-hash sha256:ed92e6bdfd6d7e27abc8f9247d6de33a7dfd56b57a250195d57647bf3138c9a4e7d7a8
```


#### Come back to Master node and executhe below commands (` Only on Master Node `)
```bash

# Verify the cluster status by executing kubectl command on the master node
kubectl get nodes


#Install CNI so that pods can communicate across nodes and also Cluster DNS to start functioning. Apply weave CNI (Container Network Interface) on the master node
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
kubectl get nodes

#Output
root@master:~# kubectl get nodes
NAME       STATUS   ROLES           AGE     VERSION
master     Ready    control-plane   6m57s   v1.24.0
worker-1   Ready    <none>          80s     v1.24.0
worker-2   Ready    <none>          2m4s    v1.24.0
root@master:~# 
```
