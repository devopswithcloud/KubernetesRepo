## Upgrade the Control plane
* Drain the node
```kubectl drain master --ignore-daemonsets --force```
* Verify the kubeadm Version
```kubeadm version```
