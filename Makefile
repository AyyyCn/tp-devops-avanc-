.PHONY: help install-argocd setup-gitops deploy-app check-status clean

help: ## Afficher l'aide
	@echo "Commandes disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install-argocd: ## Installer ArgoCD dans le cluster
	@echo "🚀 Installation d'ArgoCD..."
	@chmod +x argocd/install.sh
	@./argocd/install.sh

setup-gitops: ## Configurer le pipeline GitOps (nécessite REPO_URL)
	@if [ -z "$(REPO_URL)" ]; then \
		echo "❌ Erreur: REPO_URL requis. Usage: make setup-gitops REPO_URL=https://github.com/user/repo.git"; \
		exit 1; \
	fi
	@chmod +x scripts/setup-gitops.sh
	@./scripts/setup-gitops.sh $(REPO_URL)

deploy-app: ## Déployer l'application exemple
	@echo "📦 Déploiement de l'application..."
	@kubectl apply -f apps/example-app/application.yaml
	@echo "✅ Application déployée. Vérifiez avec: kubectl get applications -n argocd"

check-status: ## Vérifier l'état des applications ArgoCD
	@echo "📊 État des applications ArgoCD:"
	@kubectl get applications -n argocd
	@echo ""
	@echo "📦 Pods de l'application:"
	@kubectl get pods -n example-app 2>/dev/null || echo "Namespace example-app n'existe pas encore"

get-argocd-password: ## Récupérer le mot de passe admin d'ArgoCD
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

port-forward-argocd: ## Créer un port-forward vers l'interface ArgoCD
	@echo "🌐 Port-forward vers ArgoCD (https://localhost:8080)..."
	@kubectl port-forward svc/argocd-server -n argocd 8080:443

clean: ## Nettoyer les ressources (application + namespace)
	@echo "🧹 Nettoyage des ressources..."
	@kubectl delete application example-app -n argocd --ignore-not-found=true
	@kubectl delete namespace example-app --ignore-not-found=true
	@echo "✅ Nettoyage terminé"

clean-all: clean ## Nettoyer toutes les ressources incluant ArgoCD
	@echo "🧹 Nettoyage complet..."
	@kubectl delete namespace argocd --ignore-not-found=true
	@echo "✅ Nettoyage complet terminé"

