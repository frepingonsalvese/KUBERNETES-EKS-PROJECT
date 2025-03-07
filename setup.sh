#!/bin/bash

# Variables
CLUSTER_NAME="my-cluster"
REGION="us-east-1"
NODEGROUP_NAME="my-nodes"
NODE_TYPE="t3.medium"
NODE_COUNT=2
NAMESPACE="ingress-nginx"

echo "🚀 Starting EKS cluster setup..."

# Step 1: Create EKS Cluster
echo "🔧 Creating EKS Cluster..."
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --nodegroup-name $NODEGROUP_NAME \
  --node-type $NODE_TYPE \
  --nodes $NODE_COUNT

if [ $? -ne 0 ]; then
  echo "❌ Failed to create EKS cluster!"
  exit 1
fi

echo "✅ EKS Cluster created successfully."

# Step 2: Install Helm
echo "🔧 Installing Helm..."
if ! command -v helm &> /dev/null; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  if [ $? -ne 0 ]; then
    echo "❌ Failed to install Helm!"
    exit 1
  fi
else
  echo "✅ Helm is already installed."
fi

# Step 3: Add Nginx Ingress Controller Repo and Install
echo "🔧 Adding Helm repo for Nginx Ingress Controller..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

echo "🔧 Installing Nginx Ingress Controller..."
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace $NAMESPACE --create-namespace

if [ $? -ne 0 ]; then
  echo "❌ Failed to install Nginx Ingress Controller!"
  exit 1
fi

echo "✅ Nginx Ingress Controller installed successfully."

echo "🎉 EKS cluster and Helm setup completed!"
