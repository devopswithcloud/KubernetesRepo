Here's how to implement different update strategies for Kubernetes Deployments: **RollingUpdate** (default) and **Recreate**.

### Update Strategies Overview:
- **RollingUpdate**: This strategy incrementally updates Pods one by one, ensuring that some Pods are always available during the update process. This is the default strategy.
- **Recreate**: This strategy terminates all existing Pods before creating new ones, which can cause downtime but ensures a clean slate for the new Pods.

### Deployment YAML with Update Strategies:

#### 1. **RollingUpdate Strategy** (Default)
The `RollingUpdate` strategy is already the default, but you can customize its parameters for more control.

**Deployment YAML with RollingUpdate**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx-deployment
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1  # Maximum number of Pods that can be unavailable during the update
      maxSurge: 1        # Maximum number of Pods that can be created above the desired number during the update
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
        image: devopswithcloudhub/nginx:blue  # Initial image
```

**Explanation**:
- **`maxUnavailable`**: Specifies the maximum number of Pods that can be unavailable during the update. Setting this to `1` ensures at least one Pod is available.
- **`maxSurge`**: Specifies the maximum number of Pods that can be created beyond the desired number of replicas. This helps speed up the rollout.

**Apply the Deployment**:
```bash
kubectl apply -f nginx-deployment.yaml
```

**Update the Image Using RollingUpdate**:
```bash
kubectl set image deployment/nginx-deployment nginx=devopswithcloudhub/nginx:green
```

### 2. **Recreate Strategy**
The `Recreate` strategy stops all existing Pods before starting new ones. This can lead to downtime but is useful when you need to ensure no overlap between old and new Pods.

**Deployment YAML with Recreate Strategy**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx-deployment
spec:
  replicas: 2
  strategy:
    type: Recreate  # Terminate all existing Pods before creating new ones
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
        image: devopswithcloudhub/nginx:blue  # Initial image
```

**Explanation**:
- **`type: Recreate`**: Ensures that all current Pods are stopped before new ones are started. This is useful for stateful applications where multiple versions running simultaneously could cause issues.

**Apply the Deployment**:
```bash
kubectl apply -f nginx-deployment.yaml
```

**Update the Image Using Recreate**:
```bash
kubectl set image deployment/nginx-deployment nginx=devopswithcloudhub/nginx:green
```

### Verify the Deployment Strategy:
Check the status of the Deployment to ensure the update strategy is being applied:
```bash
kubectl rollout status deployment/nginx-deployment
```

### Describe the Deploy to check pods going to 0
```bash
kubectl describe deploy nginx-deployment
```

### Summary:
- **RollingUpdate Strategy**: Provides zero downtime updates by incrementally replacing Pods.
- **Recreate Strategy**: Ensures all existing Pods are stopped before starting new ones, which may cause downtime but avoids overlap between different versions.

Choose the strategy that fits your application's needs. For most stateless applications, **RollingUpdate** is preferred for zero downtime, while **Recreate** can be used for stateful applications or those needing a clean transition.