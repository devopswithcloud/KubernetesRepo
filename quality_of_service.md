## Quality of Service 
* We know that containers require resources to run the application. 
* Those resources include
  * memory
  * cpu
* Below are the classes 
### Best Effort:
* The pods that doesnot specify `requests and limits` for there containers are consdered as `lowest priority and most likely to be terminater first`.
* This happens when the node is having shortage or resources
### Burstable
* Pods that have `requests and limits` defined (limits should be greater than requests). 
* Obviously, contianer is willing to consume more resources till the limit is reached. 
* These pods have a `minimal resource guarenty`.
* When the nodes is short of resources, these pods are likely to be terminated when there are not `best effort` pods. 
### Guaranteed
* Pods that have equal amount of requests and limits.
* These are been considered as the `highest priority` pods and guaranteed not to be killed before best-effort and burstable pods.


### Below is the example for Best Effort
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: best-effort-pod
spec: 
  containers: 
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
      protocol: TCP
```
### Below is the example for Burstable
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: burstable-pod
spec: 
  containers: 
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
      protocol: TCP
    resources:
      requests:
        cpu: 100m
        memory: 100Mi
      limits:
        cpu: 200m
        memory: 200Mi
```
### Below is the example for guarenteed
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: guarenty-pod
spec: 
  containers: 
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
      protocol: TCP
    resources:
      requests:
        cpu: 100m
        memory: 100Mi
      limits:
        cpu: 100m
        memory: 100Mi
```
