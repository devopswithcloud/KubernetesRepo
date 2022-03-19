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


## Upgrade the WorkerNode
* Drain the worker node  (Note: use kubectl drain wokernode, command from master)
```kubectl drain worker-1```
* Upgrade Kubeadm on worker node 1:
```apt-get update && apt-get install -y kubeadm=1.22.2-00``
* Upgrade the kubelete configuraiton on worker node
``` kubeadm upgrade node```
* Upgrade kubectl and kubelet components on worker node1
```apt-get install -y kubelet=1.22.2-00 kubectl=1.22.2-00```
* Restart the kubelet
``` sudo systemctl daemon-reload && sudo systemctl restart kubelet ```
* Verify the nodes
``` kubectl get nodes ```
* uncordon the Worker node (Note: You need to login to master to execute the uncordon command) 
``` kubectl uncordon worker-1 ```
