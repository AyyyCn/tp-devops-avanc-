# Guide de démarrage rapide - GitOps avec ArgoCD

## 🎯 Objectif

Mettre en place un pipeline GitOps fonctionnel en 5 minutes.

## 📋 Prérequis

```bash
# Vérifier l'accès au cluster
kubectl cluster-info

# Vérifier les nodes
kubectl get nodes
```

## 🚀 Installation en 3 étapes

### Étape 1 : Installer ArgoCD

```bash
chmod +x argocd/install.sh
./argocd/install.sh
```

Attendre 2-3 minutes que tous les pods soient prêts :
```bash
kubectl get pods -n argocd -w
```

### Étape 2 : Configurer le dépôt Git

**IMPORTANT** : Modifier l'URL du dépôt dans `apps/example-app/application.yaml` :

```yaml
source:
  repoURL: https://github.com/VOTRE_USERNAME/VOTRE_REPO.git
```

Ou utiliser le script automatique :
```bash
chmod +x scripts/setup-gitops.sh
./scripts/setup-gitops.sh https://github.com/VOTRE_USERNAME/VOTRE_REPO.git
```

### Étape 3 : Déployer l'application

```bash
# Pousser le code vers Git
git add .
git commit -m "Initial GitOps setup"
git push

# Déployer l'application ArgoCD
kubectl apply -f apps/example-app/application.yaml
```

## ✅ Vérification

### Vérifier l'état d'ArgoCD

```bash
# Lister les applications
kubectl get applications -n argocd

# Voir les détails
kubectl describe application example-app -n argocd
```

### Accéder à l'interface ArgoCD

```bash
# Récupérer le mot de passe admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# Port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Ouvrir https://localhost:8080 dans le navigateur.

### Vérifier l'application déployée

```bash
# Vérifier les pods
kubectl get pods -n example-app

# Vérifier les services
kubectl get svc -n example-app

# Vérifier l'ingress
kubectl get ingress -n example-app
```

## 🔄 Workflow GitOps

1. **Modifier** les manifests dans `manifests/example-app/`
2. **Commit** et **Push** vers Git
3. **ArgoCD synchronise automatiquement** (si `syncPolicy.automated` est activé)
4. **Vérifier** dans l'interface ArgoCD ou avec `kubectl`

## 🧪 Test de synchronisation

Modifier le nombre de replicas dans `manifests/example-app/deployment.yaml` :

```yaml
spec:
  replicas: 5  # Changer de 3 à 5
```

Puis :
```bash
git add manifests/example-app/deployment.yaml
git commit -m "Scale up to 5 replicas"
git push
```

ArgoCD détectera le changement et mettra à jour automatiquement le cluster.

## 🐛 Dépannage

### ArgoCD ne synchronise pas

```bash
# Vérifier les logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller --tail=50

# Forcer une synchronisation manuelle
kubectl patch application example-app -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

### Application en état "Unknown" ou "Degraded"

```bash
# Vérifier les événements
kubectl get events -n example-app --sort-by='.lastTimestamp'

# Vérifier les logs des pods
kubectl logs -n example-app -l app=example-app
```

### Problème de connexion au dépôt Git

Vérifier que l'URL du dépôt est correcte et accessible :
```bash
kubectl get application example-app -n argocd -o yaml | grep repoURL
```

## 📚 Ressources

- [Documentation ArgoCD](https://argo-cd.readthedocs.io/)
- [GitOps Principles](https://www.gitops.tech/)
- [ArgoCD Best Practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)

