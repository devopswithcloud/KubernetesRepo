#!/bin/bash
# This script sets up a Kubernetes environment on a Linux machine running Ubuntu.
# It installs the latest stable version of Kubernetes (kubelet, kubeadm, and kubectl)
# and configures necessary system settings for Kubernetes to function correctly.

# Set the MYOS variable to detect the operating system using hostnamectl
MYOS=$(hostnamectl | awk '/Operating/ { print $3 }')

# Set the OSVERSION variable to detect the OS version using hostnamectl
OSVERSION=$(hostnamectl | awk '/Operating/ { print $4 }')

# Detect the latest stable version of Kubernetes using the GitHub API
KUBEVERSION=$(curl -s https://api.github.com/repos/kubernetes/kubernetes/releases/latest | jq -r '.tag_name')
# Remove the patch version to use the major and minor version only
KUBEVERSION=${KUBEVERSION%.*}

# Check if the operating system is Ubuntu
if [ $MYOS = "Ubuntu" ]; then
    echo "Running Ubuntu configuration..."

    ### Setting up kernel modules for Kubernetes ###
    # Load the necessary kernel module: br_netfilter, required for Kubernetes networking
    cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

    ### Installing Kubernetes components ###

    # Update the apt package index and install required packages
    sudo apt-get update && sudo apt-get install -y apt-transport-https curl

    # Add the Kubernetes apt repository's GPG key and apt source list
    curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBEVERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBEVERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    # Sleep for a few seconds to ensure the sources are correctly updated
    sleep 2

    # Update the package list again to include the Kubernetes repository and install Kubernetes components
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl

    # Prevent Kubernetes packages from being automatically updated
    sudo apt-mark hold kubelet kubeadm kubectl

    # Disable swap to ensure Kubernetes runs correctly
    sudo swapoff -a

    # Comment out the swap entry in /etc/fstab to prevent it from re-enabling on reboot
    sudo sed -i 's/\/swap/#\/swap/' /etc/fstab
fi

### Configuring sysctl parameters for Kubernetes ###
# Set required sysctl parameters for iptables bridging
sudo cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Apply the sysctl parameters without rebooting
sudo sysctl --system

### Configuring container runtime endpoint for CRI-O or containerd ###
# Set the runtime endpoint for crictl to communicate with containerd
sudo crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock

### Post-installation instructions ###
# The user is prompted to follow further instructions after initializing the control plane node.
echo 'After initializing the control plane node, follow the instructions and use the following command to install the Calico network plugin (on the control node only):'
echo 'kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml'
echo 'On the worker nodes, use the kubeadm join command provided by the control plane to join the cluster.'

# Display a colorful success message
echo -e "\e[1;34m*****************************************\e[0m"
echo -e "\e[1;34m*  Kubernetes setup completed successfully!  *\e[0m"
echo -e "\e[1;34m*****************************************\e[0m"

# Exit the script
exit
