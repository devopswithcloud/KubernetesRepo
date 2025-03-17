### **2. NodePort Service**
Exposes the application on a specific port accessible from outside the cluster.

**NodePort Service YAML**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: python-nodeport-service
spec:
  type: NodePort
  selector:
    app: python-app
  ports:
    - protocol: TCP
      port: 80        # Service port
      targetPort: 8080 # Pod's container port
      nodePort: 30007  # External NodePort (optional, Kubernetes assigns if omitted)
```

**Commands to Apply**:
```bash
kubectl apply -f nodeport-service.yaml
```

**Access**:
Use `<NodeIP>:30007` to access the application.

---