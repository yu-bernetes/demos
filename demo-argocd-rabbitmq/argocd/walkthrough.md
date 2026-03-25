# Walkthrough: ArgoCD & GitOps - Complete Guide from Scratch

This guide will walk you through setting up an ArgoCD and GitOps demonstration from scratch. By following these steps, you will be able to demonstrate automated deployments, self-healing, and version control using Kubernetes.

## 0. Prerequisites
Ensure you have the following installed on your machine:
- **Docker Desktop**
- **Minikube**
- **Kubectl**
- **Helm**

---

## Step 1: Start Your Cluster
Open your terminal (PowerShell) as an Administrator and start Minikube:

```powershell
minikube start --driver=docker
```
*Wait 1-2 minutes for completion. You can verify the status with `minikube status`.*

---

## Step 2: Prepare Application Images (v1 and v2)
Since our application code is local, we need to build the images inside the Minikube Docker environment:

1.  **Connect to Minikube's Docker Context:**
    ```powershell
    & minikube -p minikube docker-env --shell powershell | Invoke-Expression
    ```

2.  **Build v1 (Blue Theme):**
    Navigate to the `app/` directory and create the `v1` image:
    ```powershell
    cd app
    docker build -t gitops-webapp:v1 .
    ```

3.  **Prepare and Build v2 (Green Theme):**
    Open [app/app.py](app/app.py) and modify the defaults (or ensure the environment variables in Step 6 reflect the change):
    Set `VERSION="2.0"`, `THEME_COLOR="#2ecc71"`, and `THEME_NAME="Green Theme"`. Then build the `v2` image:
    ```powershell
    docker build -t gitops-webapp:v2 .
    cd ..
    ```

---

## Step 3: Prepare Your Git Repository
ArgoCD tracks changes in a Git repository. 
1.  Create a new **Public** repository on GitHub (e.g., `argocd-demo`).
2.  Upload (Push) the contents of the `gitops/` folder ([deployment.yaml](gitops/deployment.yaml) and [service.yaml](gitops/service.yaml)) to this repository.
    *   **Note:** Ensure that [deployment.yaml](gitops/deployment.yaml) initially points to `image: gitops-webapp:v1`.

---

## Step 4: Install ArgoCD
1.  **Create the Namespace:**
    ```powershell
    kubectl create namespace argocd
    ```
2.  **Install ArgoCD:**
    ```powershell
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```
3.  **Access the UI (Port Forward):**
    Open a new terminal window and run the following command (keep this terminal open):
    ```powershell
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```
4.  **Retrieve Admin Password:**
    In another terminal, run this command to decode the initial password:
    ```powershell
    $pw = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"; [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($pw))
    ```
    *Copy the output. The default username is `admin`.*

---

## Step 5: Create the Application in ArgoCD
Open `https://localhost:8080` in your browser and log in.
1.  Click **+ NEW APP**.
2.  **Application Name:** `webapp-gitops`
3.  **Project:** `default`
4.  **Sync Policy:** Select `Automatic`. 
    *   **IMPORTANT:** Check both **SELF HEAL** and **PRUNE RESOURCES**.
5.  **SOURCE:**
    *   **Repository URL:** Your GitHub repository URL.
    *   **Path:** `gitops`
6.  **DESTINATION:**
    *   **Cluster URL:** `https://kubernetes.default.svc`
    *   **Namespace:** `default`
7.  Click **CREATE**.

---

## Step 6: Live Demo Scenarios

### Scenario 1: Disaster Recovery (Self-Healing)
1.  Open the application's web page: `minikube service gitops-webapp-service`
2.  Place the ArgoCD UI and the web page side-by-side.
3.  Manually delete the deployment via terminal: `kubectl delete deployment gitops-webapp`
4.  **The Result:** ArgoCD will detect the discrepancy within seconds and automatically recreate the deployment. Refresh the web page to show it's back online.

### Scenario 2: GitOps Updates (Version Upgrade)
1.  Go to your GitHub repository and edit [deployment.yaml](gitops/deployment.yaml).
2.  Change `image: gitops-webapp:v1` to `gitops-webapp:v2`.
3.  Also update the environment variables (`env`) to set `APP_VERSION` to `"2.0"`, `THEME_NAME` to `"Green Theme"`, and `THEME_COLOR` to `"#2ecc71"`.
4.  **Commit** the changes.
5.  In the ArgoCD UI, click **REFRESH** to speed up the process.
6.  **The Result:** Watch ArgoCD sync the new state and update the pods. Refresh the web page to see the theme change from **BLUE to GREEN**.

### Scenario 3: Rollback (The GitOps Way)
1.  Suppose a bug is found in v2. To roll back, simply revert the change in Git.
2.  Go to GitHub and revert the commit or edit `deployment.yaml` back to `v1` settings.
3.  **Commit** the change.
4.  **The Result:** ArgoCD will immediately pull the "Desired State" from Git and revert the cluster to `v1`. The web page will turn back to **BLUE**.

---

## Pro-Tip: Faster Synchronization
By default, ArgoCD checks for changes every 3 minutes. To reduce this interval to 30 seconds for a smoother demo:
1. Run: `kubectl edit cm argocd-cm -n argocd`
2. Add `timeout.reconciliation: 30s` under the `data:` section.
