# Architecture du Pipeline GitOps

## Vue d'ensemble

Ce projet implémente un pipeline GitOps complet avec ArgoCD, permettant la gestion déclarative et automatisée des déploiements Kubernetes.

## Composants

### 1. ArgoCD
**Rôle** : Contrôleur GitOps qui surveille le dépôt Git et synchronise l'état du cluster.

**Fichiers** :
- `argocd/install.sh` - Installation d'ArgoCD
- `argocd/argocd-config.yaml` - Configuration ArgoCD (repositories, RBAC)

**Fonctionnalités** :
- Synchronisation automatique
- Self-healing
- Prune automatique
- Interface web pour visualisation

### 2. Applications ArgoCD
**Rôle** : Définitions des applications à déployer via GitOps.

**Fichiers** :
- `apps/example-app/application.yaml` - Application de production
- `apps/example-app-dev/application.yaml` - Application de développement

**Configuration** :
- Source : Dépôt Git et chemin des manifests
- Destination : Cluster et namespace cible
- Sync Policy : Automatique avec prune et self-heal

### 3. Manifests Kubernetes
**Rôle** : Définitions déclaratives des ressources Kubernetes.

**Structure** :
```
manifests/example-app/
├── base/              # Configuration de base (Kustomize)
├── overlays/dev/      # Overlay pour environnement dev
├── namespace.yaml     # Namespace de l'application
├── configmap.yaml     # Configuration de l'application
├── deployment.yaml    # Déploiement (pods, replicas)
├── service.yaml       # Service (exposition réseau)
└── ingress.yaml       # Ingress (routage HTTP)
```

**Technologies** :
- Kustomize pour la gestion multi-environnements
- Labels standards pour la gestion
- Health checks (liveness, readiness)

### 4. Scripts d'automatisation
**Rôle** : Simplifier l'installation et la configuration.

**Fichiers** :
- `scripts/setup-gitops.sh` - Configuration complète du pipeline
- `Makefile` - Commandes Make pour simplifier les opérations

### 5. CI/CD
**Rôle** : Validation automatique des manifests avant déploiement.

**Fichiers** :
- `.github/workflows/gitops-sync.yml` - GitHub Actions workflow

**Fonctionnalités** :
- Validation de la syntaxe YAML
- Validation Kustomize
- Notification ArgoCD (optionnel)

## Flux de données

```
┌─────────────────────────────────────────────────────────┐
│                    DÉVELOPPEUR                          │
│  Modifie les manifests dans manifests/example-app/      │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ git commit & push
                     ↓
┌─────────────────────────────────────────────────────────┐
│                  DÉPÔT GIT (GitHub)                      │
│  Source de vérité - Tous les manifests versionnés       │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Pull (toutes les 3 minutes)
                     ↓
┌─────────────────────────────────────────────────────────┐
│                    ARGOCD                                │
│  - Application Controller (surveille Git)                │
│  - Compare état Git vs état cluster                     │
│  - Applique les différences                             │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ kubectl apply
                     ↓
┌─────────────────────────────────────────────────────────┐
│              CLUSTER KUBERNETES                          │
│  - Namespace example-app                                │
│  - Deployment (3 replicas)                              │
│  - Service (ClusterIP)                                  │
│  - Ingress (routage HTTP)                              │
└─────────────────────────────────────────────────────────┘
```

## Synchronisation

### Automatique (recommandé)
```yaml
syncPolicy:
  automated:
    prune: true        # Supprime les ressources supprimées de Git
    selfHeal: true     # Restaure si modification manuelle
    allowEmpty: false  # Évite les synchronisations vides
```

**Avantages** :
- Détection automatique des changements
- Pas d'intervention manuelle
- Self-healing en cas de drift

### Manuelle
Désactiver `syncPolicy.automated` et synchroniser via :
- Interface ArgoCD
- CLI ArgoCD : `argocd app sync example-app`
- kubectl : `kubectl patch application ...`

## Multi-environnements

### Structure Kustomize

```
manifests/example-app/
├── base/                    # Configuration commune
│   └── kustomization.yaml   # Référence aux ressources de base
└── overlays/
    └── dev/                 # Environnement développement
        └── kustomization.yaml  # Personnalisations dev
```

### Exemple d'utilisation

**Base** : 3 replicas, ressources standard
**Dev** : 1 replica, ressources réduites, log level debug

### Ajouter un nouvel environnement

1. Créer `manifests/example-app/overlays/staging/kustomization.yaml`
2. Créer `apps/example-app-staging/application.yaml`
3. Configurer les différences spécifiques à staging

## Sécurité

### Secrets
- **Ne jamais** commiter les secrets en clair
- Utiliser Sealed Secrets (voir `SECRETS_MANAGEMENT.md`)
- Secrets injectés via ArgoCD ou External Secrets Operator

### RBAC
- Configuration dans `argocd/argocd-config.yaml`
- Rôles et permissions définis
- Audit trail complet

### Accès Git
- ArgoCD nécessite un accès en lecture au dépôt
- Pour dépôts privés : configurer les credentials
- Utiliser des tokens avec permissions minimales

## Monitoring et observabilité

### ArgoCD UI
- État des applications en temps réel
- Diff Git vs Cluster
- Historique des synchronisations
- Logs des opérations

### Métriques
- Temps de synchronisation
- Nombre de déploiements
- Taux de succès
- État de santé des applications

### Commandes utiles
```bash
# État des applications
kubectl get applications -n argocd

# Détails d'une application
kubectl describe application example-app -n argocd

# Événements
kubectl get events -n example-app
```

## Rollback

### Via Git
```bash
# Revenir à un commit précédent
git revert HEAD
git push
# ArgoCD synchronisera automatiquement
```

### Via ArgoCD
```bash
# Rollback vers une révision spécifique
argocd app rollback example-app <REVISION>
```

## Bonnes pratiques implémentées

✅ Source de vérité unique (Git)  
✅ Synchronisation automatique  
✅ Self-healing  
✅ Multi-environnements  
✅ Validation CI/CD  
✅ Documentation complète  
✅ Scripts d'automatisation  
✅ Gestion des secrets (guide)  
✅ Structure modulaire et extensible  

## Prochaines étapes

1. **Personnaliser** : Adapter les manifests à votre application
2. **Configurer** : Mettre à jour les URLs de dépôt Git
3. **Déployer** : Installer ArgoCD et déployer la première application
4. **Étendre** : Ajouter d'autres applications et environnements
5. **Sécuriser** : Mettre en place la gestion des secrets

