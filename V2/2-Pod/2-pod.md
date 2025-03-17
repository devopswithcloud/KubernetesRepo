Here's a comprehensive list of imperative commands for creating, managing, and working with labels on Kubernetes Pods:

### 1. **Create a Pod with Labels**
Create a new Pod and attach initial labels:
```bash
kubectl run my-pod --image=nginx:latest --labels="app=frontend,environment=production"
```

### 2. **Verify Pod Creation and Labels**
Check that the Pod has been created and view its labels:
```bash
kubectl get pods --show-labels
```

### 3. **Describe the Pod to See Detailed Information**
View detailed information, including labels:
```bash
kubectl describe pod my-pod
```

### 4. **Attach a New Label to an Existing Pod**
Add a label to an existing Pod:
```bash
kubectl label pod my-pod version=v1
```

### 5. **Verify Added Labels**
Check that the new label has been added:
```bash
kubectl get pod my-pod --show-labels
```

### 6. **Overwrite an Existing Label**
Modify an existing label on a Pod:
```bash
kubectl label pod my-pod version=v2 --overwrite
```

### 7. **Remove a Label from a Pod**
Delete a specific label from a Pod:
```bash
kubectl label pod my-pod version-
```

### 8. **Filter Pods by Label**
List Pods that have a specific label:
```bash
kubectl get pods -l app=frontend
```

### 9. **Label Multiple Pods at Once**
Add a label to multiple Pods that match a condition:
```bash
kubectl label pods -l environment=production app-version=v2
```

### 10. **Advanced Filtering with Labels**
Use complex label selectors to list Pods:
```bash
# List Pods with either environment=production or environment=staging
kubectl get pods -l 'environment in (production, staging)'

# List Pods without the label tier=frontend
kubectl get pods -l 'tier!=frontend'

# List Pods that have any label called app
kubectl get pods -l 'app'
```

### 11. **Remove Multiple Labels from a Pod**
Delete more than one label at a time:
```bash
kubectl label pod my-pod app- environment-
```

### 12. **Delete Pods by Label**
Remove all Pods with a certain label:
```bash
kubectl delete pods -l app-version=v2
```

### 13. **Annotate Pods for Additional Metadata (Bonus)**
Add annotations for non-identifying metadata:
```bash
kubectl annotate pod my-pod description="This pod is part of the dev environment"
```

### 14. **List Pods and Show Labels**
Display Pods with specific labels while showing the labels:
```bash
kubectl get pods -l app=frontend --show-labels
```