apt-mark unhold kubeadm && \
apt-get update && apt-get install -y kubeadm=1.27.2-00 && \
apt-mark hold kubeadm
kubeadm upgrade plan
kubeadm upgrade apply v1.27.2
kubectl drain master --ignore-daemonsets --force
apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y kubelet=1.27.2-00 kubectl=1.27.2-00 && \
apt-mark hold kubelet kubectl
