
# Scenario Overview

1. **Deploy a Wrong Image** – push a non‑existent tag to break rollout.
2. **Deployment Stuck** – observe `ErrImagePull` / `ImagePullBackOff`.
3. **Pause the Deployment** – freeze updates while investigating.
4. **Troubleshoot** – inspect events, describe pods, (logs if any).
5. **Fix & Resume** – set a valid image and continue rollout.
6. **Undo / Rollback** – revert to previous or specific working revision.
7. **(Optional) Lock Stable State** – pause after recovery.

---


# 0) Prereqs

* `kubectl` configured to the right cluster/namespace.
* A working Deployment (from your YAML) and a NodePort Service (below).

---

# 1) Initial Setup

## 1.1 Apply the Deployment (blue)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx-deployment
  annotations:
    kubernetes.io/change-cause: "Initial deploy (blue)"
spec:
  replicas: 2
  revisionHistoryLimit: 10
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
        ports:
        - containerPort: 80
```

```bash
kubectl apply -f nginx-deployment.yaml
kubectl rollout status deployment/nginx-deployment
kubectl get pods -l app=nginx-deployment -o wide
```

## 1.2 Create a NodePort Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx-deployment
spec:
  type: NodePort
  selector:
    app: nginx-deployment
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080    # optional fixed port (30000-32767)
```

```bash
kubectl apply -f nginx-service.yaml
kubectl get svc nginx-service
```

**Quick app test (replace `<NODE_IP>`):**

```bash
curl -I http://<NODE_IP>:30080
```

---

# 2) Break It: Deploy a Wrong Image

## 2.1 Intentionally set a non-existent tag

```bash
kubectl set image deployment/nginx-deployment \
  nginx=devopswithcloudhub/nginx:nonexistent

kubectl annotate deployment/nginx-deployment \
  kubernetes.io/change-cause="Updated to a non-existent image for testing" \
  --overwrite
```

## 2.2 Observe rollout failing

```bash
kubectl rollout status deployment/nginx-deployment
kubectl get pods -l app=nginx-deployment
```

**What you’ll see:** `ErrImagePull`, `ImagePullBackOff`, or `Failed to pull image`.

---

# 3) Pause the Deployment (stabilize while investigating)

```bash
kubectl rollout pause deployment/nginx-deployment
kubectl get deployment nginx-deployment -o jsonpath='{.spec.paused}'; echo
# expected: true
```

---

# 4) Troubleshoot

Common checks:

```bash
# Events often show exact pull errors
kubectl get events --sort-by=.lastTimestamp | tail -n 20

# Pod details (re-run if needed)
kubectl describe pod <pod-name>

# (If any container starts and logs exist)
kubectl logs <pod-name>
```

**Likely cause here:** The `:nonexistent` tag doesn’t exist.

---

# 5) Fix the Image & Resume

## 5.1 Point to a valid image (green)

```bash
kubectl set image deployment/nginx-deployment \
  nginx=devopswithcloudhub/nginx:green

kubectl annotate deployment/nginx-deployment \
  kubernetes.io/change-cause="Fixed image to green" \
  --overwrite
```

## 5.2 Resume and watch rollout

```bash
kubectl rollout resume deployment/nginx-deployment
kubectl rollout status deployment/nginx-deployment
kubectl get rs -l app=nginx-deployment
kubectl get pods -l app=nginx-deployment -o wide
```

**Confirm image:**

```bash
kubectl get deploy nginx-deployment \
  -o=jsonpath='{.spec.template.spec.containers[0].image}'; echo
# expected: devopswithcloudhub/nginx:green
```

**Service test again:**

```bash
curl -I http://<NODE_IP>:30080
```

---

# 6) Undo / Rollback Scenario

## 6.1 Check history (your annotations make this readable)

```bash
kubectl rollout history deployment/nginx-deployment
# optionally inspect one:
kubectl rollout history deployment/nginx-deployment --revision=2
```

## 6.2 Ensure not paused before rollback

```bash
kubectl get deployment nginx-deployment -o jsonpath='{.spec.paused}'; echo
# if true:
kubectl rollout resume deployment/nginx-deployment
```

## 6.3 Roll back

* **To previous revision:**

```bash
kubectl rollout undo deployment/nginx-deployment
kubectl annotate deployment/nginx-deployment \
  kubernetes.io/change-cause="Rollback to previous revision" --overwrite
```

* **To a specific known-good revision (example: 1 for blue):**

```bash
kubectl rollout undo deployment/nginx-deployment --to-revision=1
kubectl annotate deployment/nginx-deployment \
  kubernetes.io/change-cause="Rollback to revision 1 (blue)" --overwrite
```

## 6.4 Verify

```bash
kubectl rollout status deployment/nginx-deployment
kubectl get pods -l app=nginx-deployment -o wide
kubectl get deploy nginx-deployment \
  -o=jsonpath='{.spec.template.spec.containers[0].image}'; echo
```

**Service test:**

```bash
curl -I http://<NODE_IP>:30080
```

---

# 7) (Optional) Lock a Stable State

If you want to stop changes while planning the next step:

```bash
kubectl rollout pause deployment/nginx-deployment
```

---

