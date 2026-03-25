# Guide: Event-Driven Autoscaling with KEDA & RabbitMQ

This document provides a comprehensive walkthrough for a production-like demonstration of event-driven autoscaling in Kubernetes. Using **KEDA (Kubernetes Event-driven Autoscaling)** and **RabbitMQ**, we demonstrate how to scale worker pods dynamically from 0 to 30 based on message queue depth.

---

## 1. Prerequisites

Before starting, ensure you have the following tools installed and configured:

> [!IMPORTANT]
> This guide assumes a Windows environment using **PowerShell**.

- **Minikube:** Local Kubernetes cluster.
- **Docker Desktop:** Container runtime.
- **Helm:** Kubernetes package manager (`choco install kubernetes-helm`).
- **Python 3.x:** For running the message producer.

---

## 2. Infrastructure Setup

### A. Initialize Minikube
Start your local cluster using the Docker driver:
```powershell
minikube start --driver=docker
```

### B. Install KEDA
KEDA handles the autoscaling logic. Install it via Helm:
```powershell
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm install keda kedacore/keda --namespace keda --create-namespace
```

---

## 3. Prepare the Worker Image

The `worker` application consumes messages from RabbitMQ. Build it directly within the Minikube Docker environment to avoid external registry requirements:

```powershell
# Point shell to Minikube's Docker daemon
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# Build the worker image
cd worker
docker build -t worker:latest .
cd ..
```

---

## 4. Deploy Components

Apply the Kubernetes manifests in the following order:

```powershell
# Deploy RabbitMQ (Broker)
kubectl apply -f k8s/rabbitmq.yaml

# Deploy the Worker (Consumer)
kubectl apply -f k8s/worker-deployment.yaml

# Deploy KEDA ScaledObject (Autoscaler configuration)
kubectl apply -f k8s/scaled-object.yaml
```

---

## 5. Demonstration

### A. Environment Preparation
Open three separate PowerShell terminals to mirror the system state:

1.  **Terminal 1 (Observer):** Monitor real-time pod activity.
    ```powershell
    while($true) { clear; kubectl get pods -l app=worker; sleep 1 }
    ```
    *Observation:* Pod count should be **0** (Scale-to-Zero).

2.  **Terminal 2 (RabbitMQ Management):** Access the web dashboard.
    ```powershell
    kubectl port-forward service/rabbitmq 15672:15672
    ```
    *Action:* Open `http://localhost:15672` (Credentials: `guest`/`guest`).

3.  **Terminal 3 (Application Traffic):** Route traffic to the producer.
    ```powershell
    kubectl port-forward service/rabbitmq 5672:5672
    ```

### B. Execution Flow

1.  **The "Idle" State:** Show the RabbitMQ Dashboard. Highlight that there are **0 consumers** and **0 messages**. Kubernetes is consuming minimal resources.
2.  **Inject Load:** Run the producer script to flood the queue:
    ```powershell
    python producer.py
    ```
3.  **Monitor the Scaling Pulse:**
    - **Within 10s:** Observe Terminal 1. KEDA detects the queue pressure and starts provisioning pods.
    - **Within 30s:** The deployment scales to the maximum limit of **30 pods**.
    - **Dashboard Visuals:** Watch the "Message Rates" graph spike and then plummet as 30 workers consume the backlog.
4.  **The "Cooldown" Phase:** Once the queue is empty, watch as KEDA gracefully terminates the workers, returning the system to **0 pods** after the cooling period (default 1-2 mins).

---

## 6. Cleanup

To remove all resources created during this walkthrough:

```powershell
kubectl delete -f k8s/
helm uninstall keda -n keda
minikube stop
```

> [!TIP]
> Use `minikube dashboard` for a more visual overview of the scaling process within the Kubernetes UI.
