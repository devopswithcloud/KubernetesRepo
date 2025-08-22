## 1️⃣ What is a ConfigMap?

* A **ConfigMap** is used to store **non-confidential configuration data** in key-value pairs.
* Keeps your application configuration **separate from the container image**.
* Example use: Storing database URLs, application settings, feature flags.

### Ways to Use a ConfigMap

1. **As Environment Variables**
2. **As Command-line Arguments**
3. **As Files in a Volume**

### Example: Create ConfigMap

```bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=APP_DEBUG=false
```

### YAML Example

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: "production"
  APP_DEBUG: "false"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  name: siva
  course: k8s
  key3: |
    Hello
    Welcome to Config maps
    Multiline testing
```

---

## 2️⃣ What is a Secret?

* A **Secret** is used to store **sensitive data** such as passwords, tokens, keys.
* Encoded in **Base64** (not encryption, just encoding).
* Prevents exposing credentials in Pod specs.
* Kubernetes secretes has 3 available commands
    * `generic`: generic secret holds any key value pair
    * `tls`: secret for holding private-public key for communicating with TLS protocol
    * `docker-registry`: This is special kind of secret that stores usernames and passwords to connect to private registries

### Example: Create Secret

```bash
kubectl create secret generic db-secret \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASS=pa55w0rd
```

### YAML Example

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  DB_USER: YWRtaW4=       # base64 encoded 'admin'
  DB_PASS: cGE1NXcwcmQ=   # base64 encoded 'pa55w0rd'
```
