### **3. LoadBalancer Service**
Provides external access using a cloud provider's load balancer.

**LoadBalancer Service YAML**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: python-loadbalancer-service
spec:
  type: LoadBalancer
  selector:
    app: python-app
  ports:
    - protocol: TCP
      port: 80        # External port
      targetPort: 8080 # Pod's container port
```

**Commands to Apply**:
```bash
kubectl apply -f loadbalancer-service.yaml
```

**Access**:
Use the external IP assigned by the cloud provider to access the application.

---