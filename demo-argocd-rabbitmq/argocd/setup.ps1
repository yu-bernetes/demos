# setup.ps1
# Automates the setup steps from walkthrough.md

Write-Host "Step 1: Starting Minikube..." -ForegroundColor Cyan
minikube start --driver=docker

Write-Host "`nStep 2: Preparing Application Images..." -ForegroundColor Cyan
Write-Host "Connecting to Minikube's Docker Context..."
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

Write-Host "Building gitops-webapp:v1 and gitops-webapp:v2..."
Push-Location app
docker build -t gitops-webapp:v1 .
docker build -t gitops-webapp:v2 .
Pop-Location

Write-Host "`nStep 4: Installing ArgoCD..." -ForegroundColor Cyan
# Suppress error if namespace already exists
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Write-Host "`nWaiting for ArgoCD pods to get initialized (this might take a few minutes)..." -ForegroundColor Yellow
# Wait a bit for the deployments to be created by the install.yaml
Start-Sleep -Seconds 15
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=300s

Write-Host "`nConfiguring ArgoCD to sync every 5 seconds..." -ForegroundColor Cyan
$patch = '{"data":{"timeout.reconciliation":"5s"}}'
kubectl patch cm argocd-cm -n argocd --type merge -p $patch

Write-Host "Restarting ArgoCD components to apply configuration..." -ForegroundColor Yellow
kubectl rollout restart statefulset argocd-application-controller -n argocd
kubectl rollout restart deployment argocd-repo-server -n argocd
kubectl rollout restart deployment argocd-server -n argocd

Write-Host "`nRetrieving ArgoCD Admin Password..." -ForegroundColor Cyan
try {
    $pw = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
    $decoded_pw = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($pw))
    
    Write-Host "`n========================================================" -ForegroundColor Green
    Write-Host "🌟 Setup completed successfully!" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "ArgoCD UI Credentials:" -ForegroundColor Yellow
    Write-Host "Username: admin"
    Write-Host "Password: $decoded_pw"
    Write-Host "========================================================" -ForegroundColor Green
} catch {
    Write-Host "Could not retrieve the password automatically. You can retrieve it later with:" -ForegroundColor Red
    Write-Host '$pw = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"; [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($pw))'
}

Write-Host "`nTo access the ArgoCD UI, please open a NEW terminal window and run:" -ForegroundColor Cyan
Write-Host "kubectl port-forward svc/argocd-server -n argocd 8080:443" -ForegroundColor Cyan
Write-Host "`nAfter running the port-forward, open your browser to: https://localhost:8080" -ForegroundColor Cyan
Write-Host "`nDon't forget to push your gitops/ folder to a GitHub repository and follow Step 5!" -ForegroundColor Yellow

Write-Host "`n========================================================" -ForegroundColor Magenta
Write-Host "🧹 TEARDOWN / RESET INSTRUCTIONS" -ForegroundColor Magenta
Write-Host "========================================================" -ForegroundColor Magenta
Write-Host "To safely reset the demo and start over, you can run:" -ForegroundColor Cyan
Write-Host "  .\teardown.ps1" -ForegroundColor Cyan
Write-Host "`nOr run the commands manually:" -ForegroundColor Cyan
Write-Host "  kubectl delete namespace argocd   # Reinstalls ArgoCD only" -ForegroundColor Cyan
Write-Host "  minikube delete                   # Completely removes the cluster" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Magenta
