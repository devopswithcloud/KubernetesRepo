### Deployment YAML:
Start with the following initial Deployment YAML:

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
        image: devopswithcloudhub/nginx:blue  # Initial image
```

**Apply the Deployment**:
```bash
kubectl apply -f nginx-deployment.yaml
```

### Commands for Managing the Deployment:

#### Scale the Deployment:
To scale the Deployment to a different number of replicas:
```bash
kubectl scale deployment/nginx-deployment --replicas=4
```

**Explanation**: This command scales the `nginx-deployment` to 4 replicas.

#### Update the Image:
To update the Deployment to a new image:
```bash
kubectl set image deployment/nginx-deployment nginx=devopswithcloudhub/nginx:green
```

**Explanation**:
- **`kubectl set image`**: Updates the image of the `nginx` container in the `nginx-deployment` to `devopswithcloudhub/nginx:green`.
- **`kubectl annotate`**: Adds an annotation to record the change cause for tracking purposes.

### Verify the Changes:
To check the status of the Deployment and ensure the updates were successful:
```bash
kubectl rollout status deployment/nginx-deployment
```

