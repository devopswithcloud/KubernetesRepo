# gcloud commands to create 3 vms for the cluster
```bash
gcloud compute instances create master worker-1 worker-2 --create-disk=auto-delete=yes,boot=yes,image=projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20211115 --zone us-central1-a --machine-type=e2-medium
```


# To Create a User in Ubuntu follow the below steps: (`Both master and worker`)
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


# Docker Installation Guide
This guide provides step-by-step instructions for setting up the Docker repository and installing Docker Engine on Ubuntu.

## Step 1: Set up the Repository
To set up the Docker repository, follow these steps:
```bash
# Update package lists
sudo apt-get update

# Install necessary packages for repository management
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y
```
## Step 2: Add Docker's Official GPG Key
Add Docker's official GPG key to authenticate packages:
```bash
# Create a directory for Docker keyrings
sudo mkdir -p /etc/apt/keyrings

# Download and add Docker's GPG key to the keyring
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

## Step 3: Set up the Repository
Use the following command to set up the Docker repository:

```bash
# Add Docker repository to sources list
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
## Step 4: Install Docker Engine
To install Docker Engine, follow these steps:
```bash
# Update package lists
sudo apt-get update

# Install Docker Engine
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
```
## Step 5: Configure Docker
After installing Docker, you may need to configure it:

```bash
# Hold Docker packages to prevent accidental upgrades
sudo apt-mark hold docker-ce

# Add your user to the Docker group (replace 'username' with your username)
sudo usermod -aG docker username

# Verify Docker installation
sudo docker version
```
## Step 6: Restart Containerd (Optional)
```bash
# Remove Containerd configuration file
sudo rm /etc/containerd/config.toml

# Restart Containerd service
sudo systemctl restart containerd
```




# Kubernetes Installation Guide (`Both master and worker`)

This guide provides step-by-step instructions for installing Kubernetes on Ubuntu.

## Step 1: Install Prerequisites

```bash
# First, install necessary packages for apt repository management:
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
```

## Step 2: Add Kubernetes Repository Key
```bash
# Add the Kubernetes repository key to securely authenticate packages:
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```
## Step 3: Add Kubernetes Repository
```bash
# Add the Kubernetes repository to your system's list of package sources:
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
## Step 4: Update Package Lists
```bash
# Update the package lists to fetch information about the latest versions of packages available:
sudo apt-get update
```

## Step 5: Install Kubernetes Components
```bash
# Install Kubernetes components including kubelet, kubeadm, and kubectl:
sudo apt-get install -y kubeadm=1.28.9-2.1 kubelet=1.28.9-2.1 kubectl=1.28.9-2.1
```
## Step 6: Hold Kubernetes Packages
```bash
# To prevent accidental upgrades of Kubernetes packages, hold them at their current version:
sudo apt-mark hold kubelet kubeadm kubectl
```
Congratulations! 🎉 You have successfully completed the installation of Kubernetes on your Ubuntu system. Now you're ready to dive into the exciting world of container orchestration!


-------------------

# On the Kube master server (` Master Only `)
```bash

# Initialising the control-plane node run the below command on the (master node)
sudo kubeadm init

# If we get error wrt container runtime not running , execute the below commands

rm /etc/containerd/config.toml
systemctl restart containerd
```


# Kubernetes Local Configuration Setup
This guide provides instructions for setting up the local kubeconfig file and generating a new token if needed.

## Set up Local kubeconfig
To configure your local kubeconfig file to communicate with the Kubernetes cluster, follow these steps:

```bash
# Create the directory for kubeconfig file
mkdir -p $HOME/.kube

# Copy the admin.conf file to the kubeconfig directory
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Change ownership of the kubeconfig file to the current user
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
This will ensure that you can interact with the Kubernetes cluster using kubectl from your local machine.

# Generate New Token (Optional) (`Only on Worker Nodes`)
```
# If you need to generate a new tokem use the below command (Optional Not required , if you have the above token generated)
sudo kubeadm token create --print-join-command
```


### Join the Worker nodes (`Only on Worker Nodes`)
```bash
Execute the command that is been generated as the output of the previous command, where we got the token generated. 
It will be similar to the below command

sudo kubeadm join 10.18.0.30:6443 --token 06fdx2qa.v2jxfdfdflapu54gi3s41 --discovery-token-ca-cert-hash sha256:ed92e6bdfd6d7e27abc8f9247d6de33a7dfd56b57a250195d57647bf3138c9a4e7d7a8
```


## Come back to Master node and executhe below commands (` Only on Master Node `)
```bash

# Verify the cluster status by executing kubectl command on the master node
kubectl get nodes


#Install CNI so that pods can communicate across nodes and also Cluster DNS to start functioning. Apply weave CNI (Container Network Interface) on the master node
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
kubectl get nodes

```
