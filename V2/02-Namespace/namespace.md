
## **Kubernetes Namespaces – Concept + Hands-On Lab**
## **1️⃣ Understanding Namespaces**

### **What is a Namespace?**

Think of your **Kubernetes cluster** as a **big apartment building**.

* Many families (applications) live inside.
* Each family gets **their own flat (namespace)**.
* Even though they share the same building, their rooms, kitchens, and belongings are **separate**.

Without namespaces:

* Everyone lives in **one big hall** – messy, noisy, and hard to manage.
* Two people might name their dog “Tommy” (two pods with the same name) — confusion happens.

With namespaces:

* Each family gets their own flat, so **names can repeat** without conflict.
* Resources are **organized and isolated**.
* Maintenance and security are easier.

---

### **Why Do We Need Namespaces?**

* **Avoid name clashes** (two teams can name their pod `nginx` in their own namespaces).
* **Organize environments** (dev, stage, prod).
* **Control access** (give permissions per namespace).
* **Manage resources** (set limits per team).

---

### **Default Namespaces in a Cluster**

| **Namespace**     | **Apartment Example**      | **Purpose**                       |
| ----------------- | -------------------------- | --------------------------------- |
| `default`         | Common area everyone uses  | For resources without a namespace |
| `kube-system`     | Building maintenance staff | Kubernetes internal system pods   |
| `kube-public`     | Public notice board        | Readable by everyone              |
| `kube-node-lease` | Node health tracker        | Node heartbeats                   |

---

### **i27 Academy Real Example**

At i27Academy, we can use:

* `i27-dev` → For student practice
* `i27-stage` → For testing before final deployment
* `i27-prod` → For live projects

---

💡 **One-Line Definition for namespace**

> A namespace is like giving each team their own room in the same building so they don’t mess with each other’s stuff.

---

## **2️⃣ Hands-On Lab – i27 Naming Convention**

**Naming Rule for i27 Labs:**

* Namespace: `i27-<purpose>`
* Pods: `i27-<appname>`
* Files: `<resource>-<purpose>.yaml`

---

### **Step 1 – View existing namespaces**

```bash
kubectl get ns
```

---

### **Step 2 – Create a new namespace**

#### Imperative:

```bash
kubectl create ns i27-dev
```

#### Declarative:

```bash
cat <<EOF > namespace-i27-dev.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: i27-dev
EOF

kubectl apply -f namespace-i27-dev.yaml
```

Verify:

```bash
kubectl get ns
```

---

### **Step 3 – Deploy a pod in the namespace**

```bash
kubectl run i27-nginx --image=nginx -n i27-dev
kubectl get pods -n i27-dev
```

---

### **Step 4 – Switch to i27-dev namespace**

```bash
kubectl config set-context --current --namespace=i27-dev
kubectl get pods
```

---

### **Step 5 – Create another resource in the namespace**

```bash
kubectl run i27-busybox --image=busybox --restart=Never -- sleep 3600
kubectl get pods
```

---

### **Step 6 – Delete the namespace**

```bash
kubectl delete ns i27-dev
kubectl get ns
```

---

### **Step 7 – (Optional) Resource Quota**

```bash
kubectl create ns i27-stage
cat <<EOF > quota-i27-stage.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: i27-stage-quota
  namespace: i27-stage
spec:
  hard:
    pods: "2"
    requests.cpu: "1"
    requests.memory: 2Gi
    limits.cpu: "2"
    limits.memory: 4Gi
EOF

kubectl apply -f quota-i27-stage.yaml
kubectl describe quota i27-stage-quota -n i27-stage
```

### **Interview Tip**

> "Namespaces help isolate workloads and manage resources within a single Kubernetes cluster. They’re crucial for multi-tenant environments."

---
