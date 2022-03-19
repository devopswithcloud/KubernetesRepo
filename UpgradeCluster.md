## Upgrade the Control plane
* Drain the node
```kubectl drain master --ignore-daemonsets --force```
* Verify the kubeadm Version
```kubeadm version```
* Upgrade kubeadm
```apt-get update && apt-get install -y --allow-change-held-packages kubeadm=1.22.2-00 ```
* Plan the upgrade
```kubeadm upgrade plan ```
* Plan the upgrade to a specific version
``` kubeadm upgrade plan v1.22.2```
* upgrade the control plan components 
``` kubeadm upgrade apply v1.22.2```
* Upgrade the Kubelet and Kubectl on the control plane
``` apt-get install -y kubelet=1.22.2-00 kubectl=1.22.2-00 ```
* Restart the kubelet
``` sudo systemctl daemon-reload && sudo systemctl restart kubelet ```
* Verify the nodes
``` kubectl get nodes ```
* uncordon the control plan node 
``` kubectl uncordon master```
