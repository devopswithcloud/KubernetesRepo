
### ClusterIP Service Exampl
#### **Step 1: Deployment and Service YAML**
Use the following YAML to create a Deployment and expose it using a **ClusterIP Service**.

**ClusterIP Deployment and Service YAML**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-app
  labels:
    app: python-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: python-app
  template:
    metadata:
      labels:
        app: python-app
    spec:
      containers:
      - name: python-webpage
        image: devopswithcloudhub/python_webpage:blue
        ports:
        - containerPort: 8080  # Application's container port
---
apiVersion: v1
kind: Service
metadata:
  name: python-clusterip-service
spec:
  selector:
    app: python-app
  ports:
    - protocol: TCP
      port: 80       # Service port
      targetPort: 8080 # Pod's container port
```

**Apply the YAML**:
```bash
kubectl apply -f clusterip-deployment.yaml
kubectl apply -f clusterip-service.yaml
```

---

#### **Step 2: Verify the ClusterIP Service**
Check the Service details:
```bash
kubectl get svc python-clusterip-service
```

**Expected Output**:
```plaintext
NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
python-clusterip-service   ClusterIP   10.96.123.45    <none>        80/TCP    5m
```

Note the **ClusterIP** (e.g., `10.96.123.45`).

---

#### **Step 3: Test the ClusterIP Service from Within the Cluster**
To verify that the Service is accessible, create a temporary Pod and test it.

1. **Create a Test Pod**:
   ```bash
   kubectl run test-pod --rm -it --image=busybox -- /bin/sh
   ```

   **Explanation**:
   - `--rm`: Deletes the Pod automatically after exiting.
   - `-it`: Opens an interactive shell session.
   - `busybox`: A lightweight image with utilities like `wget` for testing.

2. **Test the Service Using DNS Name**:
   Inside the test Pod shell, use the DNS name of the Service:
   ```sh
   # Ensure the Service and Deployment are in the same namespace. If not, you must use the fully qualified DNS name (e.g., python-clusterip-service.<namespace>.svc.cluster.local)
   wget -qO- python-clusterip-service.default.svc.cluster.local:80
   ```

   **Expected Output**:
   You should see the response from the `python-webpage` application.

3. **Test the Service Using ClusterIP**:
   Alternatively, use the ClusterIP of the Service:
   ```sh
   wget -qO- 10.96.123.45:80
   ```

   **Expected Output**:
   Similar to the DNS test, you should see the response from the application.

4. **Exit the Test Pod**:
   After testing, exit the test Pod session:
   ```sh
   exit
   ```

---

#### **Step 4: Troubleshooting**
If you encounter issues while testing, follow these steps:

- **Verify Pods**:
  Ensure the Pods are running and ready:
  ```bash
  kubectl get pods
  ```

- **Check Service Endpoints**:
  Confirm that the Service is correctly linked to the Pods:
  ```bash
  kubectl get endpoints python-clusterip-service
  ```

  **Expected Output**:
  The IPs of the Pods backing the Service.

- **Access Pods Directly**:
  If the Service is unreachable, try accessing the Pods directly from the test Pod:
  ```sh
  wget -qO- <pod-ip>:8080
  ```

---

### Summary of Steps:
1. **Deploy the Application**:
   - Use the YAML to deploy the `python-app` and expose it with a **ClusterIP Service**.
2. **Verify the Service**:
   - Check the Service's ClusterIP and endpoints.
3. **Test the Service**:
   - Use a temporary Pod to test the Service internally via DNS or ClusterIP.
4. **Troubleshoot**:
   - Verify Pods and endpoints if there are issues.
