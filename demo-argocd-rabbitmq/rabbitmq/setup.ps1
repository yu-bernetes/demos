# setup.ps1
# Script to get the project up and running based on walkthrough.md

Write-Host "1. Starting Minikube..." -ForegroundColor Green
minikube start --driver=docker

Write-Host "`n2. Installing KEDA..." -ForegroundColor Green
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm install keda kedacore/keda --namespace keda --create-namespace

Write-Host "`n3. Building the Worker Image..." -ForegroundColor Green
# Point shell to Minikube's Docker daemon
& minikube -p minikube docker-env --shell powershell | Invoke-Expression

# Build the worker image
cd worker
docker build -t worker:latest .
cd ..

Write-Host "`n4. Deploying Components..." -ForegroundColor Green
kubectl apply -f k8s/rabbitmq.yaml
kubectl apply -f k8s/worker-deployment.yaml
kubectl apply -f k8s/scaled-object.yaml

Write-Host "`n=======================================================" -ForegroundColor Cyan
Write-Host "Setup complete! The project is now up and running." -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan

Write-Host "`nNext Steps for Demo:" -ForegroundColor Yellow
Write-Host "Open three separate PowerShell terminals and run:"
#Write-Host "  Terminal 1 (Observer):        while(`$true) { clear; kubectl get pods -l app=worker; sleep 1 }"
Write-Host "  Terminal 1 (RabbitMQ Dash):   kubectl port-forward service/rabbitmq 15672:15672"
Write-Host "  Terminal 2 (App Traffic):     kubectl port-forward service/rabbitmq 5672:5672"
Write-Host "`nThen run the producer to inject load:"
Write-Host "  python producer.py"

Write-Host "`nTo clean up resources afterwards, run:" -ForegroundColor Yellow
Write-Host "  kubectl delete -f k8s/"
Write-Host "  helm uninstall keda -n keda"
Write-Host "  minikube stop"
