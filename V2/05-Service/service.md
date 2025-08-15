## **Kubernetes Services – Complete Guide**

### 1️⃣ **Why Services Are Needed**

* **Problem**: Pods have dynamic IPs — when a pod dies or restarts, the IP changes.
* **Need**: We require a **stable networking endpoint** to communicate with applications.
* **Solution**: **Kubernetes Service** — provides a **permanent virtual IP** (ClusterIP) and DNS name.

---

### 2️⃣ **What is a Service?**

* An **abstraction** that defines a logical set of Pods and a policy to access them.
* Uses **selectors** to match pods (via labels).
* Exposes applications running in one or more Pods.

---

### 3️⃣ **Types of Services**

| Type                    | Scope                                                     | Accessibility                           | Use Case                                          |
| ----------------------- | --------------------------------------------------------- | --------------------------------------- | ------------------------------------------------- |
| **ClusterIP** (default) | Inside cluster only                                       | No external access                      | Internal communication (e.g., frontend → backend) |
| **NodePort**            | Exposes on every node’s IP at a static port (30000–32767) | External access via `<NodeIP>:NodePort` | Development/testing                               |
| **LoadBalancer**        | Integrates with cloud provider’s LB                       | External IP with LB routing             | Production-ready external access                  |
| **Headless Service**    | No ClusterIP assigned                                     | Direct pod IPs via DNS                  | StatefulSets, custom service discovery            |

---

### 4️⃣ **Service Key Components**

* **Selector** → Defines which pods are targeted (via labels)
* **Port** → Port the service listens on
* **TargetPort** → Port on the pod
* **Protocol** → TCP/UDP
* **ClusterIP** → Internal service IP

---

### 5️⃣ **Hands-on Examples**

#### Example 1 – ClusterIP

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-clusterip-svc
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

#### Example 2 – NodePort

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nodeport-svc
spec:
  type: NodePort
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080
```

#### Example 3 – LoadBalancer (Cloud Environment)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-lb-svc
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

---

### 6️⃣ **DNS and Service Discovery**

* Services get an internal DNS name like:

  ```
  <service-name>.<namespace>.svc.cluster.local
  ```
* Example: `my-clusterip-svc.default.svc.cluster.local`

---

### 7️⃣ **Real-world Use Cases**

* **ClusterIP** → Communication between frontend and backend microservices.
* **NodePort** → Quick testing from local machine.
* **LoadBalancer** → Production public endpoint.
* **Headless** → Databases like Cassandra, Stateful apps.

---
