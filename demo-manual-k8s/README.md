# Kubernetes & Docker Technical Demonstration Guide

This repository contains the deployment configurations and source code to demonstrate **7 advanced Kubernetes features** actively used in the industry. The following guide provides step-by-step instructions to reproduce these scenarios.

---

## 🛠️ Preparation (Initial Setup)
Open a terminal in the directory and execute the following commands in order:

**1. Build the initial "Version 1" (v1) image:**
```bash
docker build -t flask-k8s-demo:v1 .
```

**2. Initialize Kubernetes Resources:**
```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

*Verify that the system is up and running by executing `kubectl get pods`. Ensure that 3 pods are in the `Running` state.*

---

## 🚀 DEMO 1: Load Balancing & Visual UI
The application is now accessible. Open a web browser and navigate to `http://localhost:80`. The "Version 1.0" blue-themed interface will be displayed.
*   Observe the **Pod Name** displayed in the center of the screen.
*   Refresh the page consecutively (**F5**). Notice how the incoming traffic is sequentially distributed across the 3 different pods (the Pod Name changes on each refresh), demonstrating Kubernetes Service load balancing.

---

## 🛡️ DEMO 2: Self-Healing
Kubernetes is designed for high availability. This scenario demonstrates what happens when a container crashes.
1. Copy the name of one of the running pods using: `kubectl get pods`
2. Forcefully delete the selected Pod to simulate a failure: `kubectl delete pod <copied-pod-name>`
3. IMMEDIATELY run `kubectl get pods` again. Observe that Kubernetes detects the missing pod within seconds and automatically creates a new one (`ContainerCreating` or `Running` state) to maintain the desired replica count.

---

## ⚙️ DEMO 3: ConfigMap (Runtime Configuration)
Best practices dictate separating configuration from code. This demo shows how to update environment variables without rebuilding the Docker image.
1. Open the `k8s/configmap.yaml` file. Change the value `APP_VERSION: "1.0"` to `"1.5 Beta"` and save the file.
2. Apply the configuration change to the cluster: `kubectl apply -f k8s/configmap.yaml`
3. Trigger a restart so the Pods pick up the new configuration: `kubectl rollout restart deployment flask-demo-deployment`
4. Check the browser to verify that the version text has dynamically updated to "1.5 Beta" (The color will also turn Green).
5. **Important Cleanup:** Before proceeding to the next demos, revert the `APP_VERSION` back to `"1.0"` in `k8s/configmap.yaml`, apply it (`kubectl apply -f k8s/configmap.yaml`), and restart the deployment (`kubectl rollout restart deployment flask-demo-deployment`) so it returns to Blue.

---

## 🚨 DEMO 4: Liveness Probe (Crash Simulation)
Simulating an internal software failure where the application becomes unresponsive.
1. Navigate to `http://localhost:80` in your browser.
2. Click the red **"Simulate Crash"** button and confirm the prompt.
3. Refresh the page consecutively. Occasionally, the page will return a red "Internal Server Error".
4. Monitor the cluster state in the terminal using: `kubectl get pods -w`
5. Observe how Kubernetes' Liveness Probe detects the failing Pod, increments the "RESTARTS" count, and automatically restarts the container to restore the application to a healthy state.

---

## 🔥 DEMO 5: Auto-scaling (Horizontal Pod Autoscaler)
This scenario demonstrates dynamic scaling based on CPU utilization thresholds.
1. If the Metrics Server is not installed (Run this only once):
   `kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`
   `kubectl patch deployment metrics-server -n kube-system --type 'json' -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'`
2. Apply the HPA policy: `kubectl apply -f k8s/hpa.yaml`
3. Monitor the scaling process in the terminal (leave it open): `kubectl get hpa -w`
4. OPEN A NEW TERMİNAL and start the load testing script: `python load_test.py`
*(Note: If a ModuleNotFoundError occurs, run `pip install requests` first)*
5. Observe the terminal as CPU utilization spikes, triggering the replica count to automatically scale from 3 up to 10 pods to handle the load. As the load decreases, it will scale back down.

---

## 🔄 DEMO 6: Zero-Downtime Deployment
Upgrading the application to Version 2.0 (Green Theme) without any service interruption.
1. Build the new Docker image tagged as v2: `docker build -t flask-k8s-demo:v2 .`
2. Group the Environment Variable and Image updates into a single atomic release:
   ```bash
   kubectl rollout pause deployment/flask-demo-deployment
   kubectl set env deployment/flask-demo-deployment APP_VERSION=2.0
   kubectl set image deployment/flask-demo-deployment flask-demo-container=flask-k8s-demo:v2
   kubectl rollout resume deployment/flask-demo-deployment
   ```
3. Continuously refresh the browser. Observe the seamless transition from the blue (V1) interface to the green (V2) interface without encountering any connection drops or errors.

---

## ⏪ DEMO 7: Instant Rollback
Simulating a scenario where a critical bug is discovered in deployment V2.0, requiring an immediate rollback.
Execute the following undo command in the terminal:
```bash
kubectl rollout undo deployment flask-demo-deployment
```
Refresh the browser to verify that the application has instantly and safely reverted to the stable Version 1.0 (Blue) state without downtime.

---

## 🧹 Cleanup
To remove all created resources from the cluster:
```bash
kubectl delete -f k8s/hpa.yaml
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/configmap.yaml
```