```bash
#apt-mark unhold kubeadm && \
#apt-get update && apt-get install -y kubeadm=1.27.2-00 && \

apt-mark unhold kubeadm && apt-get update && apt-get install -y kubeadm=1.28.10-1.1 && apt-mark hold kubeadm

apt-mark hold kubeadm
kubeadm upgrade plan
kubedm upgrade apply v1.28.10
kubectl drain master --ignore-daemonsets --force
sudo apt-get install --only-upgrade kubelet=1.28.10-1.1
sudo systemctl restart kubelet


apt-cache madison kubeadm
apt-cache madison kubelet



apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y kubelet=1.27.2-00 kubectl=1.27.2-00 && \
apt-mark hold kubelet kubectl
kubectl uncordon master
```
