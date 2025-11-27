# Principes GitOps

## 🎯 Qu'est-ce que le GitOps ?

Le GitOps est une méthodologie qui utilise Git comme source de vérité unique pour l'infrastructure et les applications. Tous les changements sont effectués via des commits Git, garantissant traçabilité, auditabilité et reproductibilité.

## 📐 Principes fondamentaux

### 1. Déclaratif
Tout est décrit de manière déclarative dans des fichiers YAML/JSON. L'état désiré est défini, pas les étapes pour y arriver.

### 2. Versionné
Tous les manifests sont versionnés dans Git. Chaque changement est tracé, revu et peut être rollbacké.

### 3. Automatisé
Les changements sont automatiquement appliqués au cluster. Pas d'intervention manuelle nécessaire.

### 4. Observabilité
L'état actuel vs l'état désiré est toujours visible et mesurable.

## 🔄 Flux GitOps

```
┌─────────────┐
│   Git Repo  │ ← Source de vérité
│  (Manifests)│
└──────┬──────┘
       │
       │ Pull
       ↓
┌─────────────┐
│   ArgoCD    │ ← Contrôleur GitOps
│  (Controller)│
└──────┬──────┘
       │
       │ Apply
       ↓
┌─────────────┐
│ Kubernetes  │ ← Cluster cible
│   Cluster   │
└─────────────┘
```

## ✅ Avantages

### Traçabilité
- Historique complet de tous les changements
- Qui a fait quoi et quand
- Lien direct entre code et déploiement

### Sécurité
- Review process via Pull Requests
- Audit trail complet
- Pas de modifications manuelles directes sur le cluster

### Stabilité
- Rollback instantané vers n'importe quel commit
- Tests avant déploiement (via CI)
- Environnements reproductibles

### Collaboration
- Workflow standardisé
- Review par les pairs
- Documentation intégrée (via Git)

## 🏗️ Architecture recommandée

### Structure du dépôt

```
repo/
├── apps/              # Définitions ArgoCD Application
│   ├── app1/
│   └── app2/
├── manifests/         # Manifests Kubernetes
│   ├── app1/
│   │   ├── base/
│   │   └── overlays/
│   └── app2/
└── argocd/           # Configuration ArgoCD
```

### Multi-environnements

Utiliser Kustomize overlays pour gérer différents environnements :

```
manifests/app1/
├── base/
│   ├── deployment.yaml
│   └── kustomization.yaml
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    ├── staging/
    │   └── kustomization.yaml
    └── prod/
        └── kustomization.yaml
```

## 🔐 Bonnes pratiques

### 1. Séparation des préoccupations
- Un dépôt par équipe/projet OU
- Un dépôt monorepo avec structure claire

### 2. Branching strategy
- `main` : Production
- `staging` : Environnement de staging
- `develop` : Développement

### 3. Pull Requests obligatoires
- Tous les changements via PR
- Review obligatoire
- Tests automatiques

### 4. Tags et releases
- Taguer les versions stables
- Utiliser semantic versioning
- ArgoCD peut pointer vers des tags spécifiques

### 5. Secrets management
- Ne jamais commiter les secrets
- Utiliser Sealed Secrets, External Secrets, ou Vault
- Secrets injectés via ArgoCD

## 🚫 Anti-patterns à éviter

### ❌ Modifications manuelles
Ne jamais modifier directement le cluster avec `kubectl apply` ou via l'interface. Tout doit passer par Git.

### ❌ Secrets en clair
Ne jamais commiter les secrets en clair dans Git.

### ❌ Dépôts multiples non synchronisés
Éviter d'avoir plusieurs sources de vérité. Un seul dépôt GitOps par cluster/environnement.

### ❌ Synchronisation manuelle
Éviter de synchroniser manuellement. Utiliser `syncPolicy.automated`.

## 📊 Métriques et observabilité

### Métriques à suivre
- Temps de synchronisation
- Nombre de déploiements par jour
- Taux de succès des déploiements
- Temps de rollback

### Outils
- ArgoCD UI pour visualisation
- Prometheus pour métriques
- Grafana pour dashboards

## 🎓 Ressources d'apprentissage

- [Weaveworks GitOps](https://www.weave.works/technologies/gitops/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [CNCF GitOps Working Group](https://github.com/cncf/tag-app-delivery/tree/main/gitops-wg)

