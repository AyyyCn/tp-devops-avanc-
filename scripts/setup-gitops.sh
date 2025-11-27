#!/bin/bash

set -e

REPO_URL="${1:-}"
REPO_PATH="${2:-.}"

if [ -z "$REPO_URL" ]; then
    echo "❌ Erreur: URL du dépôt Git requise"
    echo "Usage: $0 <REPO_URL> [REPO_PATH]"
    echo "Exemple: $0 https://github.com/username/repo.git"
    exit 1
fi

echo "🔧 Configuration du pipeline GitOps..."

# Installer ArgoCD si nécessaire
if ! kubectl get namespace argocd &>/dev/null; then
    echo "📦 Installation d'ArgoCD..."
    bash "$REPO_PATH/argocd/install.sh"
    sleep 10
fi

# Mettre à jour l'URL du dépôt dans les applications
echo "📝 Configuration de l'URL du dépôt Git: $REPO_URL"

# Mettre à jour tous les fichiers application.yaml
find "$REPO_PATH/apps" -name "application.yaml" -type f | while read -r app_file; do
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|repoURL:.*|repoURL: $REPO_URL|g" "$app_file"
    else
        sed -i "s|repoURL:.*|repoURL: $REPO_URL|g" "$app_file"
    fi
    echo "   ✓ Mis à jour: $app_file"
done

echo ""
echo "✅ Configuration terminée!"
echo ""
echo "📋 Prochaines étapes:"
echo "   1. Commiter et pousser les changements vers Git:"
echo "      git add ."
echo "      git commit -m 'Configure GitOps pipeline'"
echo "      git push"
echo ""
echo "   2. Déployer l'application ArgoCD:"
echo "      kubectl apply -f apps/example-app/application.yaml"
echo ""
echo "   3. Vérifier l'état dans ArgoCD:"
echo "      kubectl get applications -n argocd"

