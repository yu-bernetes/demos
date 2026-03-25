# teardown.ps1
# Resets the environment for the GitOps demo

Write-Host "========================================================" -ForegroundColor Magenta
Write-Host "🧹 TEARDOWN / RESET INSTRUCTIONS" -ForegroundColor Magenta
Write-Host "========================================================" -ForegroundColor Magenta
Write-Host "What would you like to do?"
Write-Host "1) Delete only ArgoCD (Fastest way to reset the demo)"
Write-Host "2) Delete the entire Minikube cluster (Complete reset)"
Write-Host "3) Cancel"

$choice = Read-Host "Enter your choice (1-3)"

if ($choice -eq "1") {
    Write-Host "`nDeleting ArgoCD namespace... (this may take a minute)" -ForegroundColor Yellow
    kubectl delete namespace argocd
    Write-Host "ArgoCD deleted. You can run setup.ps1 again to reinstall." -ForegroundColor Green
} elseif ($choice -eq "2") {
    Write-Host "`nDeleting Minikube cluster..." -ForegroundColor Yellow
    minikube delete
    Write-Host "Minikube cluster deleted. Start from scratch by running setup.ps1." -ForegroundColor Green
} else {
    Write-Host "Operation cancelled. No changes made." -ForegroundColor Cyan
}
