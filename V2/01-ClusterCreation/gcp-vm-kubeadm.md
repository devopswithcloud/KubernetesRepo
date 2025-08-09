# Kubeadm on Google Cloud VMs — End-to-End Demo Guide (Ubuntu 22.04 + containerd + Calico)

**Goal:** Provision GCP infrastructure with Terraform, configure all nodes, and bootstrap a Kubernetes cluster using kubeadm, containerd, and Calico.

---

## 1) Provision GCP Infrastructure (Terraform)

**`main.tf`**

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.30"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

variable "project_id" {}
variable "region" { default = "us-central1" }
variable "zone"   { default = "us-central1-a" }
variable "machine_type" { default = "e2-medium" }

resource "google_compute_network" "vpc" {
  name                    = "kubeadm-net"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "kubeadm-subnet"
  ip_cidr_range = "10.10.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_firewall" "ssh_icmp" {
  name    = "kubeadm-allow-ssh-icmp"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  allow { protocol = "icmp" }
  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_firewall" "k8s_cp" {
  name    = "kubeadm-k8s-cp"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["6443","2379-2380","10250-10259"]
  }
  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "k8s_workers" {
  name    = "kubeadm-k8s-workers"
  network = google_compute_network.vpc.name
  allow { 
    protocol = "tcp" 
    ports = ["10250","30000-32767","179"] 
  }
  allow { 
    protocol = "udp" 
    ports = ["4789"] 
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_all" {
  name    = "kubeadm-allow-all"
  network = google_compute_network.vpc.name
  allow { protocol = "all" }
  source_ranges = ["0.0.0.0/0"]
}

locals {
  instances = {
    cp1 = var.machine_type
    w1  = var.machine_type
    w2  = var.machine_type
  }
}

resource "google_compute_instance" "vm" {
  for_each     = local.instances
  name         = each.key
  machine_type = each.value
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
      size  = 30
    }
  }

  network_interface {
    subnetwork   = google_compute_subnetwork.subnet.id
    access_config {}
  }

  metadata = { enable-oslogin = "TRUE" }
  tags     = ["kubeadm-net"]
}

output "cp_internal_ip" { value = google_compute_instance.vm["cp1"].network_interface[0].network_ip }
output "worker_ips" { value = [for k, v in google_compute_instance.vm : v.network_interface[0].network_ip if k != "cp1"] }
```

**Run:**

```bash
export TF_VAR_project_id="your-project-id"
terraform init
terraform apply -auto-approve
terraform output cp_internal_ip
terraform output worker_ips
```

---

## 2) Base Node Setup (ALL nodes)

**File:** `base-setup.sh`

```bash
#!/usr/bin/env bash
set -euxo pipefail

sudo swapoff -a
sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab
echo -e "overlay\nbr_netfilter" | sudo tee /etc/modules-load.d/k8s.conf
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# Install containerd from Docker's official repo
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg apt-transport-https
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y containerd.io chrony

# Install cri-tools from Kubernetes release
CRICTL_VERSION="v1.30.0"
curl -LO https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz
sudo tar zxvf crictl-${CRICTL_VERSION}-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-${CRICTL_VERSION}-linux-amd64.tar.gz

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/^disabled_plugins = .*/disabled_plugins = []/' /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl daemon-reexec
sudo systemctl enable --now containerd
sudo systemctl restart containerd

sudo ctr plugins ls | grep cri || true
sudo crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock
sudo crictl info | head || true

# Install Kubernetes packages
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now chrony
```

**Run on ALL nodes:**

```bash
sudo bash ~/base-setup.sh | tee ~/base-setup.log
```

---

## 3) Control Plane Init (ONLY cp1)

```bash
export POD_CIDR="192.168.0.0/16"
export APISERVER_ADVERTISE_ADDRESS="$(hostname -I | awk '{print $1}')"
# dont execute the below command if no issues are observerd during initialisation
#sudo kubeadm reset -f || true
sudo kubeadm init --pod-network-cidr=${POD_CIDR} --apiserver-advertise-address=${APISERVER_ADVERTISE_ADDRESS}
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

## 4) Calico CNI (cp1)

```bash
curl -L https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml -o calico.yaml
kubectl apply -f calico.yaml
kubectl -n kube-system rollout status ds/calico-node --timeout=120s
```

---

## 5) Join Workers (w1, w2)

On cp1:

```bash
kubeadm token create --print-join-command
```

Run output on each worker.

---

## 6) Validate (cp1)

```bash
kubectl get nodes -o wide
kubectl create deployment hello --image=nginx:1.25
kubectl expose deployment hello --type=NodePort --port=80
kubectl get svc hello -o wide
```

---

## 7) Troubleshooting

If CRI missing:

```bash
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/^disabled_plugins = .*/disabled_plugins = []/' /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
```

---

## 8) Cleanup

```bash
terraform destroy -auto-approve
```
