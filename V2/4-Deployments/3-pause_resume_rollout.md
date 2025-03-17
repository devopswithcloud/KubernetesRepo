Let's create scenarios based on the provided Deployment YAML and NodePort service to simulate deploying a wrong image, troubleshooting, pausing, and resuming updates.

### Scenario Overview:
1. **Deploy a Wrong Image**: Deploy an image that will fail (e.g., a non-existent image).
2. **Deployment Stuck**: Observe how the Deployment behaves when it is unable to pull the image.
3. **Pause the Deployment**: Pause the Deployment to prevent further actions while troubleshooting.
4. **Troubleshoot the Issue**: Inspect and diagnose the problem.
5. **Resume the Deployment**: Fix the issue and resume the Deployment.

### Initial Setup:
Ensure you have the following initial Deployment YAML for reference:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-deployment
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - name: nginx
        image: devopswithcloudhub/nginx:blue
```

### Step 1: Deploy a Wrong Image
Update the Deployment with an incorrect or non-existent image.

**Command:**
```bash
kubectl set image deployment/nginx-deployment nginx=devopswithcloudhub/nginx:nonexistent
kubectl annotate deployment/nginx-deployment kubernetes.io/change-cause="Updated to a non-existent image for testing"
```

**Expected Outcome:**
- The Deployment will attempt to pull the `devopswithcloudhub/nginx:nonexistent` image.
- Pods will go into a `CrashLoopBackOff` or `ImagePullBackOff` state because the image cannot be found.

**Verify the Status:**
```bash
kubectl rollout status deployment/nginx-deployment
```

**Check Pod Status:**
```bash
kubectl get pods
```
**Optional(Above yaml with annotation included)**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx-deployment
  annotations:
    kubernetes.io/change-cause: "Updated to a non-existent image for testing"
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-deployment
  template:
    metadata:
      labels:
        app: nginx-deployment
    spec:
      containers:
      - name: nginx
        image: devopswithcloudhub/nginx:blue
```
### Step 2: Observe the Deployment Stuck State
When the Deployment is unable to update successfully, it will be stuck. Pods will display a status indicating that the image pull failed.

**Describe a Pod for More Details:**
```bash
kubectl describe pod <pod-name>
```

**Look for Error Messages**:
- You will see messages like `Failed to pull image` or `ErrImagePull`.

### Step 3: Pause the Deployment
Pause the Deployment to stop further updates and stabilize the current state while you troubleshoot.

**Pause Command:**
```bash
kubectl rollout pause deployment/nginx-deployment
```

**Verify Paused Status:**
```bash
kubectl get deployment nginx-deployment -o jsonpath='{.spec.paused}'
```

**Expected Output:**
```
true
```

### Step 4: Troubleshoot the Issue
1. **Check Pod Logs** (if any logs are available before failure):
   ```bash
   kubectl logs <pod-name>
   ```
2. **Describe the Pods** to understand more about why they are failing:
   ```bash
   kubectl describe pod <pod-name>
   ```

**Common Troubleshooting Steps**:
- Confirm that the image name is correct.
- Ensure the image tag exists in the container registry.

### Step 5: Fix the Image and Resume the Deployment
Correct the image in the Deployment to use a valid image and resume the rollout.

**Set the Correct Image**:
```bash
kubectl set image deployment/nginx-deployment nginx=devopswithcloudhub/nginx:green
kubectl annotate deployment/nginx-deployment kubernetes.io/change-cause="Fixed image to green"
```

**Resume the Deployment**:
```bash
kubectl rollout resume deployment/nginx-deployment
```

**Verify the Deployment Rollout**:
```bash
kubectl rollout status deployment/nginx-deployment
```

**Check Pod Status**:
```bash
kubectl get pods
```

### Final Verification:
- Access the service using the NodePort to ensure the application is running correctly.
- Verify that the new Pods are using the `devopswithcloudhub/nginx:green` image:
  ```bash
  kubectl get pods -o wide
  ```

### Summary:
- **Deploying a Wrong Image**: Simulated a deployment failure by using a non-existent image.
- **Paused Deployment**: Paused the Deployment to prevent further updates while troubleshooting.
- **Troubleshooting**: Used commands like `kubectl describe pod` and `kubectl logs` to diagnose the issue.
- **Resuming**: Corrected the image and resumed the Deployment.
