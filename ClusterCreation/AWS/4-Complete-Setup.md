# Documentation for Setting Up AWS Infrastructure and Kubernetes Cluster
* This guide will take you through the steps required to create the infrastructure on AWS
* Set up containers, and configure Kubernetes on a master and two worker nodes. 
* Please follow the steps in the given order to ensure a smooth and successful setup.


## Step 1: Infrastructure Creation on AWS
* Run the 1-infra-creation.sh script to create the necessary infrastructure on AWS. This script will:
    * This script creates a security group, allows all inbound traffic,
    * launches three EC2 instances: one master and two workers.
    * Optionally, you can specify the instance type. The default is t3.medium.
    * if issue with AMIID, do change it accordingly, i have taken north-virginia
```bash
./1-Infra-Creation.sh
```


## Step 2: Container Runtime Setup
* After the infrastructure is created, execute the `2-container-setup.sh` script on each node (master, worker-1, and worker-2). 
* This script sets up the container runtime on a Linux machine
```bash
./2-container-setup.sh
```

## Step 3: Kubernetes Installation
* Once the container runtime is installed, proceed with installing Kubernetes on the `master and worker nodes` by running the `3-Kubernetes-setup.sh` script on each node.
```bash
./3-Kubernetes-setup.sh
```

## Step 4: Kubeadm init - On the Kube master server (` Master Only `)
```bash
# Initialising the control-plane node run the below command on the (master node)
sudo kubeadm init
```

## Step 5: Kubernetes Local Configuration Setup
* To manage the Kubernetes cluster using kubectl, you need to set up the local kubeconfig file on the master node:


### Set up Local kubeconfig
To configure your local kubeconfig file to communicate with the Kubernetes cluster, follow these steps:

```bash
# Create the directory for kubeconfig file
mkdir -p $HOME/.kube

# Copy the admin.conf file to the kubeconfig directory
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

# Change ownership of the kubeconfig file to the current user
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
* This will ensure that you can interact with the Kubernetes cluster using kubectl from your local machine.



## Step 6: Generate New Token (Optional) (`On Master Nodes`)
```
# If you need to generate a new tokem use the below command (Optional Not required , if you have the above token generated)
sudo kubeadm token create --print-join-command
```


## Step 7: Join the Worker nodes (`Only on Worker Nodes`)
```bash
Execute the command that is been generated as the output of the previous command, where we got the token generated. 
It will be similar to the below command

sudo kubeadm join 10.18.0.30:6443 --token 06fdx2qa.v2jxfdfdflapu54gi3s41 --discovery-token-ca-cert-hash sha256:ed92e6bdfd6d7e27abc8f9247d6de33a7dfd56b57a250195d57647bf3138c9a4e7d7a8
```


## Step 8: Install the Calico Network Add-On
```bash
# On the control plane node, install Calico Networking:
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Check status of the control plane node:
kubectl get nodes

## Come back to Master node and executhe below commands (` Only on Master Node `)
```bash

# Verify the cluster status by executing kubectl command on the master node
kubectl get nodes

