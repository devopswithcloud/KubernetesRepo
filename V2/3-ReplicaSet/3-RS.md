### Part 1: Demonstrating Replica Sets (RS)

#### Step 1: Create Initial Pods with Various Labels
Create a set of Pods to demonstrate how RS selectors work with label matching.

```bash
kubectl run hydpod --image=nginx --labels="env=dev,tier=frontend,dc=hyd"
kubectl run mumpod --image=nginx --labels="env=dev,tier=frontend,dc=mum"
kubectl run chennaipod --image=nginx --labels="env=dev,tier=frontend,dc=chen"
kubectl run appod --image=nginx --labels="env=dev,tier=rs,dc=hyd"
kubectl run bangalorepod --image=nginx --labels="env=nondev,tier=frontend,dc=chen"
```

### Part 1.1: Create a Replica Set Using `matchLabels`

##### `matchLabels` YAML Configuration:
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend-matchlabels
spec:
  replicas: 3
  selector:
    matchLabels:
      env: dev  # Matches Pods that have the label 'env=dev'
  template:
    metadata:
      labels:
        env: dev
        tier: frontend
    spec:
      containers:
        - image: nginx
          name: frontend-container
```

**Explanation**:
- **`matchLabels` Logic**: The RS will only select and manage Pods with the `env=dev` label. It uses **AND logic**, so if additional labels were specified, Pods would need to match **all** of them to be selected.

#### Apply the `matchLabels` YAML:
```bash
kubectl apply -f replica-set-matchlabels.yaml
```

#### Verify the `matchLabels` RS:
```bash
kubectl get pods --show-labels
kubectl describe replicaset frontend-matchlabels
```

#### Cleanup (Optional):
```bash
kubectl delete replicaset frontend-matchlabels
```

---

### Part 1.2: Create a Replica Set Using `matchExpressions`

##### `matchExpressions` YAML Configuration:
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend-matchexpressions
spec:
  replicas: 3
  selector:
    matchLabels:
      env: dev  # Base label requirement
    matchExpressions:
      - { key: tier, operator: In, values: [frontend, rs] }  # Matches 'tier' as 'frontend' or 'rs'
      - { key: dc, operator: NotIn, values: [mum, hyd] }    # Excludes 'dc' as 'mum' or 'hyd'
  template:
    metadata:
      labels:
        env: dev
        tier: frontend
    spec:
      containers:
        - image: nginx
          name: frontend-container
```

**Explanation**:
- **`matchLabels`**: Matches Pods with `env=dev`.
- **`matchExpressions`**:
  - The first condition requires `tier` to be `frontend` or `rs`.
  - The second condition excludes Pods where `dc` is `mum` or `hyd`.

#### Detailed Evaluation Example: Why Only `chennaipod` Is Selected
Let's evaluate each Pod against the criteria:

1. **`hydpod` (env=dev, tier=frontend, dc=hyd)**:
   - **`matchLabels`**: Matches `env=dev` → ✅
   - **`matchExpressions`**:
     - `tier` is `frontend` → ✅
     - `dc` is `hyd` → ❌ (Fails `NotIn` condition)
   - **Result**: Not selected because `dc=hyd` violates the `NotIn` condition.

2. **`mumpod` (env=dev, tier=frontend, dc=mum)**:
   - **`matchLabels`**: Matches `env=dev` → ✅
   - **`matchExpressions`**:
     - `tier` is `frontend` → ✅
     - `dc` is `mum` → ❌ (Fails `NotIn` condition)
   - **Result**: Not selected because `dc=mum` violates the `NotIn` condition.

3. **`chennaipod` (env=dev, tier=frontend, dc=chen)**:
   - **`matchLabels`**: Matches `env=dev` → ✅
   - **`matchExpressions`**:
     - `tier` is `frontend` → ✅
     - `dc` is `chen` → ✅ (Passes `NotIn` condition)
   - **Result**: Selected because it satisfies **all** conditions in both `matchLabels` and `matchExpressions`.

4. **`appod` (env=dev, tier=rs, dc=hyd)**:
   - **`matchLabels`**: Matches `env=dev` → ✅
   - **`matchExpressions`**:
     - `tier` is `rs` → ✅
     - `dc` is `hyd` → ❌ (Fails `NotIn` condition)
   - **Result**: Not selected because `dc=hyd` violates the `NotIn` condition.

5. **`bangalorepod` (env=nondev, tier=frontend, dc=chen)**:
   - **`matchLabels`**: Does **not** match `env=dev` → ❌
   - **Result**: Not selected because it fails the `matchLabels` requirement.

#### Apply the `matchExpressions` YAML:
```bash
kubectl apply -f replica-set-matchexpressions.yaml
```

#### Verify the `matchExpressions` RS:
```bash
kubectl get pods --show-labels
kubectl describe replicaset frontend-matchexpressions
```

#### Cleanup (Optional):
```bash
kubectl delete replicaset frontend-matchexpressions
```