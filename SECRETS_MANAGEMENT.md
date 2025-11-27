# Gestion des Secrets avec GitOps

## ⚠️ Principe fondamental

**NE JAMAIS commiter les secrets en clair dans Git.**

## 🔐 Solutions recommandées

### 1. Sealed Secrets (Recommandé pour débuter)

Sealed Secrets chiffre les secrets dans Git. Seul le cluster peut les déchiffrer.

#### Installation

```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml
```

#### Utilisation

```bash
# Installer kubeseal
# Windows: choco install kubeseal
# Linux: wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/kubeseal-0.24.0-linux-amd64.tar.gz

# Créer un secret
kubectl create secret generic mysecret \
  --from-literal=password=supersecret \
  --dry-run=client -o yaml | kubeseal -o yaml > sealed-secret.yaml

# Le fichier sealed-secret.yaml peut être commité en toute sécurité
```

### 2. External Secrets Operator

Intègre avec des providers externes (AWS Secrets Manager, HashiCorp Vault, etc.)

### 3. ArgoCD + Vault

Utiliser Vault comme source de secrets, injectés via ArgoCD.

## 📝 Exemple avec Sealed Secrets

### Créer un secret scellé

```bash
# 1. Créer le secret Kubernetes normal
kubectl create secret generic app-secret \
  --from-literal=db-password=mysecretpassword \
  --from-literal=api-key=myapikey \
  --namespace example-app \
  --dry-run=client -o yaml > /tmp/secret.yaml

# 2. Sceller le secret
kubeseal < /tmp/secret.yaml -o yaml > manifests/example-app/sealed-secret.yaml

# 3. Supprimer le fichier temporaire
rm /tmp/secret.yaml

# 4. Commiter sealed-secret.yaml
git add manifests/example-app/sealed-secret.yaml
git commit -m "Add sealed secret for app"
```

### Utiliser le secret dans le deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-app
spec:
  template:
    spec:
      containers:
      - name: app
        env:
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: db-password
```

## 🔄 Workflow recommandé

1. **Développement local** : Utiliser des secrets locaux (non commités)
2. **CI/CD** : Générer les sealed secrets automatiquement
3. **Git** : Commiter uniquement les sealed secrets
4. **ArgoCD** : Déploie les sealed secrets qui sont déchiffrés automatiquement

## 🛡️ Bonnes pratiques

- Utiliser des secrets différents par environnement
- Rotation régulière des secrets
- Audit des accès aux secrets
- Limiter les permissions RBAC
- Utiliser des secrets avec expiration

