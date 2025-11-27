# Pipeline GitOps avec ArgoCD

Ce projet implémente un pipeline GitOps complet utilisant ArgoCD pour automatiser le déploiement et la synchronisation de l'état du cluster Kubernetes à partir d'un dépôt Git.

## Architecture GitOps

```
Git Repository (Source of Truth)
    ↓
ArgoCD (Controller)
    ↓
Kubernetes Cluster
```

## Structure du projet

```
.
├── apps/                          # Applications ArgoCD
│   ├── example-app/
│   │   └── application.yaml
│   └── example-app-dev/
│       └── application.yaml
├── manifests/                     # Manifests Kubernetes
│   └── example-app/
│       ├── base/                  # Base Kustomize
│       ├── overlays/              # Overlays par environnement
│       │   └── dev/
│       ├── namespace.yaml
│       ├── configmap.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       └── kustomization.yaml
├── argocd/                        # Configuration ArgoCD
│   ├── install.sh                 # Script d'installation
│   └── argocd-config.yaml         # Configuration ArgoCD
├── scripts/                       # Scripts utilitaires
│   └── setup-gitops.sh            # Configuration complète
├── .github/workflows/             # CI/CD GitHub Actions
│   └── gitops-sync.yml
├── Makefile                       # Commandes Make simplifiées
├── README.md                      # Ce fichier
├── QUICKSTART.md                  # Guide de démarrage rapide
├── GITOPS_PRINCIPLES.md           # Principes GitOps
└── SECRETS_MANAGEMENT.md          # Gestion des secrets
```

## Prérequis

- Cluster Kubernetes fonctionnel (minikube, kind, ou cloud)
- `kubectl` configuré et connecté au cluster
- Accès en écriture au dépôt Git

## Installation rapide

### Option 1 : Utiliser Make (recommandé)

```bash
# Installer ArgoCD
make install-argocd

# Configurer avec votre dépôt Git
make setup-gitops REPO_URL=https://github.com/VOTRE_USERNAME/VOTRE_REPO.git

# Déployer l'application
make deploy-app
```

### Option 2 : Installation manuelle

#### 1. Installer ArgoCD

```bash
chmod +x argocd/install.sh
./argocd/install.sh
```

#### 2. Configurer le dépôt Git

Modifier `apps/example-app/application.yaml` et remplacer `YOUR_USERNAME/YOUR_REPO` par votre dépôt.

Ou utiliser le script :
```bash
chmod +x scripts/setup-gitops.sh
./scripts/setup-gitops.sh https://github.com/VOTRE_USERNAME/VOTRE_REPO.git
```

#### 3. Accéder à l'interface ArgoCD

```bash
# Récupérer le mot de passe admin
make get-argocd-password

# Port-forward (dans un terminal séparé)
make port-forward-argocd
```

Accéder à : https://localhost:8080
- Username: `admin`
- Password: (celui récupéré ci-dessus)

#### 4. Déployer une application via GitOps

```bash
# Pousser le code vers Git
git add .
git commit -m "Initial GitOps setup"
git push

# Déployer l'application ArgoCD
kubectl apply -f apps/example-app/application.yaml
```

ArgoCD va automatiquement :
1. Surveiller le dépôt Git
2. Détecter les changements
3. Synchroniser l'état du cluster avec les manifests Git

> 📖 Pour un guide détaillé, voir [QUICKSTART.md](QUICKSTART.md)

## Workflow GitOps

1. **Développement** : Modifier les manifests dans `manifests/`
2. **Commit** : Pousser les changements vers Git
3. **Synchronisation** : ArgoCD détecte et applique automatiquement les changements
4. **Vérification** : Consulter l'état dans l'interface ArgoCD

## Synchronisation automatique

Par défaut, ArgoCD synchronise automatiquement les applications configurées avec `syncPolicy: automated`.

## Commandes utiles

### Avec Make

```bash
make help                    # Afficher toutes les commandes
make check-status           # Vérifier l'état des applications
make get-argocd-password    # Récupérer le mot de passe admin
make port-forward-argocd    # Accéder à l'interface ArgoCD
make clean                  # Nettoyer les ressources
```

### Avec kubectl

```bash
# Lister les applications ArgoCD
kubectl get applications -n argocd

# Voir les détails d'une application
kubectl describe application example-app -n argocd

# Vérifier les pods déployés
kubectl get pods -n example-app

# Voir les événements
kubectl get events -n example-app --sort-by='.lastTimestamp'
```

### Avec ArgoCD CLI (si installé)

```bash
# Synchronisation manuelle
argocd app sync example-app

# Voir l'état de l'application
argocd app get example-app

# Voir l'historique
argocd app history example-app
```

## Fonctionnalités

### ✨ Multi-environnements
- Structure Kustomize avec base et overlays
- Exemple d'environnement dev inclus
- Facilement extensible pour staging/prod

### 🔄 Synchronisation automatique
- Détection automatique des changements Git
- Self-healing : restauration automatique en cas de drift
- Prune automatique des ressources supprimées

### 🔐 Gestion des secrets
- Guide complet pour Sealed Secrets
- Bonnes pratiques de sécurité
- Voir [SECRETS_MANAGEMENT.md](SECRETS_MANAGEMENT.md)

### 🧪 Validation CI/CD
- GitHub Actions pour validation des manifests
- Tests automatiques avant déploiement
- Intégration avec le workflow GitOps

## Avantages du GitOps

- **Source de vérité unique** : Git comme référence absolue
- **Traçabilité** : Historique complet des changements
- **Rollback facile** : Revenir à n'importe quel commit
- **Collaboration** : Review process via Pull Requests
- **Sécurité** : Audit trail complet
- **Reproductibilité** : Environnements identiques et reproductibles

## Documentation complémentaire

- [QUICKSTART.md](QUICKSTART.md) - Guide de démarrage rapide
- [GITOPS_PRINCIPLES.md](GITOPS_PRINCIPLES.md) - Principes et bonnes pratiques
- [SECRETS_MANAGEMENT.md](SECRETS_MANAGEMENT.md) - Gestion sécurisée des secrets

## Ressources

- [Documentation ArgoCD](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://www.gitops.tech/)
- [Kustomize Documentation](https://kustomize.io/)

