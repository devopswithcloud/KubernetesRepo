## Create a private GKE Cluster

```bash
gcloud config set compute/zone us-central1-a


#  Create a private cluster
gcloud beta container clusters create my-private-cluster \
    --enable-private-nodes \
    --master-ipv4-cidr 172.16.0.16/28 \
    --enable-ip-alias \
    --machine-type "e2-small" \
    --num-nodes "1" \
    --disk-size "50"
    --create-subnetwork ""
# Verify a new subnet should be created in the default VPC
```

## Create a public GKE Cluster
```bash
#  Create a public cluster
gcloud beta container clusters create my-public-cluster \
    --machine-type "e2-small" \
    --num-nodes "1" \
    --disk-size "50"
```
## Create a VM - Jump server to connect to the gke cluster
```bash
# Creata  a JumpServer
gcloud compute instances create jump-server --zone us-central1-a --scopes 'https://www.googleapis.com/auth/cloud-platform'
```
## Run the following to Authorize your external address range,
```bash
gcloud container clusters update my-private-cluster \
    --enable-master-authorized-networks \
    --master-authorized-networks {JUMPSERVER_PUBLIC_IP]/32

# Login to jumpserver
gcloud compute ssh jump-server --zone us-central1-a

#install kubectl
sudo apt-get install kubectl

# Confgure the config file using gcloud command
gcloud container clusters get-credentials my-private-cluster --zone us-central1-a

#kubectl get nodes

# Create a deployment to test the access to private gke from customers
kubectl create deploy siva-nginx --image nginx

#Expose the deploy  to access 
kubectl expose deploy siva-nginx --port 80 --type LoadBalancer
```
