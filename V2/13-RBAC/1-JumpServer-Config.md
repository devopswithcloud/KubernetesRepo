# maha user 

# Generating a private key 
openssl genrsa -out maha.key 2048

# Generating a Certificate Signing Request
openssl req -new -key maha.key -out maha.csr -subj "/CN=maha/O=devops"

# SCP ca.key and ca.crt from master node to jumpserver using the below commands
scp ca.crt maha@PUBLIC_IP:/home/maha/
scp ca.key maha@PUBLIC_IP:/home/maha/

# Generating a self-signed certificate
openssl x509 -req -days 365 -in maha.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial -out maha.crt

# Create a kubeconfig file, set the cluster
kubectl config set-cluster kubeadmcluster --server https://10.128.0.16:6443 --certificate-authority=ca.crt

# Create a kubeconfig file, set the user
kubectl config set-credentials maha --client-certificate=maha.crt --client-key=maha.key

# Create a kubeconfig file, set the context
kubectl config set-context mahacontext --cluster=kubeadmcluster --user=maha

# Use the context
kubectl config use-context mahacontext
