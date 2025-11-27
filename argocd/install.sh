#!/bin/bash

set -e

echo "🚀 Installation d'ArgoCD..."

# Créer le namespace ArgoCD
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Installer ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Attente du déploiement d'ArgoCD..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd || true

echo "✅ ArgoCD installé avec succès!"
echo ""
echo "📋 Informations d'accès:"
echo "   - Récupérer le mot de passe admin:"
echo "     kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "   - Port-forward vers l'interface:"
echo "     kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "   - Accéder à: https://localhost:8080"
echo "     Username: admin"

