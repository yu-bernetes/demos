# Kubernetes & Cloud Native Demonstrations 🚀

Welcome to the Kubernetes and Cloud Native demonstrations repository! This repository contains a collection of practical, step-by-step guides and code to help you explore and demonstrate various advanced features of Kubernetes, GitOps, and Event-Driven Architecture.

## 📂 Repository Contents

This repository is divided into two main demonstration environments:

### 1. [Manual Kubernetes Features (`demo-manual-k8s`)](./demo-manual-k8s/)
A comprehensive guide demonstrating **7 advanced Kubernetes features** actively used in the industry. It uses a simple Python Flask application to showcase Kubernetes native capabilities.

**Key Scenarios Covered:**
*   **Load Balancing & Visual UI:** How Kubernetes Services distribute traffic.
*   **Self-Healing:** Automatic pod recreation upon failure.
*   **ConfigMap (Runtime Configuration):** Updating environment variables dynamically.
*   **Liveness Probe (Crash Simulation):** Detecting and recovering from internal app failures.
*   **Auto-scaling (HPA):** Scaling pods dynamically based on CPU utilization.
*   **Zero-Downtime Deployment:** Seamless transition between application versions.
*   **Instant Rollback:** Reverting to a previous stable state without downtime.

👉 **[Go to the Manual K8s Demo](./demo-manual-k8s/README.md)**

---

### 2. [GitOps & Event-Driven Autoscaling (`demo-argocd-rabbitmq`)](./demo-argocd-rabbitmq/)
This section contains two distinct, advanced Cloud Native patterns focusing on GitOps workflows and scale-to-zero event-driven architectures.

#### A. ArgoCD & GitOps
A complete guide from scratch to set up ArgoCD and demonstrate a GitOps workflow.
**Key Scenarios Covered:**
*   **Disaster Recovery (Self-Healing):** ArgoCD automatically correcting cluster state drifts.
*   **GitOps Updates:** Triggering application version upgrades via Git commits.
*   **Rollback:** Reverting applications seamlessly using Git history.

👉 **[Go to the ArgoCD Walkthrough](./demo-argocd-rabbitmq/argocd/walkthrough.md)**

#### B. KEDA & RabbitMQ (Event-Driven Autoscaling)
A production-like demonstration of event-driven autoscaling using KEDA (Kubernetes Event-driven Autoscaling).
**Key Scenarios Covered:**
*   **Scale-to-Zero:** Consuming no resources when idle.
*   **Event-Driven Provisioning:** Dynamically scaling workers from 0 to 30 based on RabbitMQ message queue depth.
*   **Cooldown Phase:** Graceful termination of workers back to 0 once the queue is empty.

👉 **[Go to the KEDA & RabbitMQ Walkthrough](./demo-argocd-rabbitmq/rabbitmq/walkthrough.md)**

---

## 🛠️ General Prerequisites
While each demo has its specific requirements, having the following tools installed is generally recommended:
*   [Docker Desktop](https://www.docker.com/products/docker-desktop/)
*   [Minikube](https://minikube.sigs.k8s.io/docs/start/) or any local Kubernetes cluster
*   [Kubectl](https://kubernetes.io/docs/tasks/tools/)
*   [Helm](https://helm.sh/)

_Follow the specific instructions inside each demo's folder to get started!_
