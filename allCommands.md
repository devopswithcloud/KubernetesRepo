### Namespaces
```bash
kubectl get ns or kubectl get namespace 
kubectl create namespace my-first-namespace
kubectl get pods # It will fetch the pods in the default namespace
kubectl get pods -n my-first-namespace # Gets the pods in my-first-namespace
kubectl get pods -A
kubectl get pods --all-namespaces
```

### Pods
```bash
kubectl run nginx --image nginx

# Attach a label to a pod
kubectl run nginx --image nginx --labels app=frontend,owner=siva

#Filter pods based on labels
kubectl get pods -l app=frontend

# Label an existing pod
kubectl label pod my-pod day=thursday billing=free

# Remove a label
 kubectl label pod my-pod day-

# Delete a pod based on labels
kubectl delete pod -l app=frontend,owner=siva

# Overwrite an existing label
kubectl label pod my-pod4 app=backend billing=myown --overwrite

# Describe the pods
kubectl describe pod <podname>

# Expose a pod
kubectl expose pod my-pod --port 80 --target-port 80 --type NodePort

# Port Forwarding to test in localhost
 sudo kubectl port-forward my-pod 8084:80

# Login to pod
kubectl exec -it podname -- /bin/bash

# Dry run pod
 kubectl run yamlpod --image nginx --dry-run=client -o yaml > yamlpo.yaml 

# Explain Pod
kubectl explain pods

kubectl get pods --v 6
kubectl get pods -o wide --sort-by .spec.nodeName

# Kubectl cheatsheet
https://kubernetes.io/docs/reference/kubectl/cheatsheet/