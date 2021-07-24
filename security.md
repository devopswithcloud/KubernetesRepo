###
```bash
adduser username
#Add the new user to the sudo group 

usermod -aG sudo username
# Update the apt package index and install packages needed to use the Kubernetes apt repository:
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Download the Google Cloud public signing key:
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

# Add the Kubernetes apt repository:
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl with a specific version, and pin their version:
sudo apt-get update
sudo apt-get install -y kubectl=1.19.1-00
sudo apt-mark hold kubectl

vi /etc/ssh/sshd_config # Make password authentication yes
sudo service ssh restart

#Generate a private key for DevDan and Certificate Signing Request (CSR) for maha
openssl genrsa -out DevDan.key 2048

openssl req -new -key maha.key \ -out maha.csr -subj "/CN=maha/O=development"

#Generate a self-signed certificate. Use the CA keys for the Kubernetes cluster and set the certificate expiration.

sudo openssl x509 -req -in maha.csr \ 
  -CA /etc/kubernetes/pki/ca.crt \ 
  -CAkey /etc/kubernetes/pki/ca.key \ -CAcreateserial \ -out maha.crt -days 45
```

