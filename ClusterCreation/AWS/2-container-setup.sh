#!/bin/bash
# This script sets up the container runtime on a Linux machine,
# with specific support for both AMD64 and ARM64 architectures.
# The script also installs the latest versions of containerd and runc.

# Detect the operating system and version using hostnamectl
MYOS=$(hostnamectl | awk '/Operating/ { print $3 }')
OSVERSION=$(hostnamectl | awk '/Operating/ { print $4 }')

# Detect the platform architecture (AMD64 or ARM64)
# The arch command returns the architecture type, and this sets the PLATFORM variable accordingly.
[ $(arch) = aarch64 ] && PLATFORM=arm64
[ $(arch) = x86_64 ] && PLATFORM=amd64

# Install jq, a lightweight and flexible command-line JSON processor, which is required to parse JSON data later in the script.
sudo apt install -y jq

# Check if the operating system is Ubuntu
if [ $MYOS = "Ubuntu" ]; then
    ### Setting up prerequisites for the container runtime ###

    # Load necessary kernel modules: overlay and br_netfilter
    cat <<- EOF | sudo tee /etc/modules-load.d/containerd.conf
    overlay
    br_netfilter
EOF

    # Load the kernel modules immediately
    sudo modprobe overlay
    sudo modprobe br_netfilter

    # Set up required sysctl parameters for Kubernetes-related networking
    # These settings are required for proper networking functionality in containerized environments.
    cat <<- EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
    net.bridge.bridge-nf-call-iptables  = 1
    net.ipv4.ip_forward                 = 1
    net.bridge.bridge-nf-call-ip6tables = 1
EOF

    # Apply the sysctl parameters without rebooting the system
    sudo sysctl --system

    ### Installing containerd ###

    # Retrieve the latest version number of containerd from GitHub
    CONTAINERD_VERSION=$(curl -s https://api.github.com/repos/containerd/containerd/releases/latest | jq -r '.tag_name')
    # Remove the 'v' prefix from the version number (if present)
    CONTAINERD_VERSION=${CONTAINERD_VERSION#v}

    # Download the containerd binary for the detected platform architecture
    wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-${PLATFORM}.tar.gz
    
    # Extract and install containerd to /usr/local
    sudo tar xvf containerd-${CONTAINERD_VERSION}-linux-${PLATFORM}.tar.gz -C /usr/local

    # Create a configuration file for containerd
    sudo mkdir -p /etc/containerd
    cat <<- TOML | sudo tee /etc/containerd/config.toml
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".containerd]
      discard_unpacked_layers = true
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
TOML

    ### Installing runc ###

    # Retrieve the latest version number of runc from GitHub
    RUNC_VERSION=$(curl -s https://api.github.com/repos/opencontainers/runc/releases/latest | jq -r '.tag_name')

    # Download the runc binary for the detected platform architecture
    wget https://github.com/opencontainers/runc/releases/download/${RUNC_VERSION}/runc.${PLATFORM}

    # Install the runc binary to /usr/local/sbin with the appropriate permissions
    sudo install -m 755 runc.${PLATFORM} /usr/local/sbin/runc

    ### Starting and enabling containerd service ###

    # Download the systemd service file for containerd
    wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

    # Move the service file to the systemd directory
    sudo mv containerd.service /usr/lib/systemd/system/

    # Reload systemd to apply the new service file and enable/start the containerd service
    sudo systemctl daemon-reload
    sudo systemctl enable --now containerd
fi

echo -e "\e[1;32m*****************************************\e[0m"
echo -e "\e[1;32m*   Container runtime setup successful!  *\e[0m"
echo -e "\e[1;32m*****************************************\e[0m"

# Exit the script
exit
