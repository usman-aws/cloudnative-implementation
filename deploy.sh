#!/bin/bash
set -e

echo "=== Phase 1: Provision Minikube cluster ==="
minikube start \
  --profile=todo-app \
  --driver=docker \
  --memory=2500 \
  --cpus=2 \
  --kubernetes-version=v1.30.0 \
  --cni=calico \
  --force

minikube update-context --profile=todo-app
echo "Cluster ready. Context: $(kubectl config current-context)"

echo ""
echo "=== Phase 2: Deploy manifests with Terraform ==="
cd "$(dirname "$0")/terraform/envs/local"
terraform init -input=false
terraform apply -input=false -auto-approve

echo ""
echo "=== Deployment complete ==="
terraform output
