# ApplicationSet - Team Workloads

## Directory Structure

The `teams-applicationset.yaml` uses the git directory generator to discover applications automatically. The expected structure is:

```
apps/
  <team>/
    <environment>/
      <service-name>/
        values.yaml      # Helm values for this team/env/service combination
        Chart.yaml       # Optional: if service has its own chart
```

### Example

```
apps/
  commerce/
    dev/
      order-service/
        values.yaml
      payment-service/
        values.yaml
    staging/
      order-service/
        values.yaml
    prod/
      order-service/
        values.yaml
```

## How It Works

1. The ApplicationSet controller watches the `apps/` directory in this repo
2. For every discovered directory at depth 4 (`apps/<team>/<env>/<service>/`), it creates one ArgoCD `Application`
3. The Application is named `<service>-<team>-<env>` and deployed to namespace `<team>-<env>`
4. ArgoCD syncs the Helm chart specified by `values.yaml` in that directory

## Adding a New App

To onboard a new service for your team:

```bash
# Create the directory
mkdir -p apps/<your-team>/<environment>/<service-name>

# Add a values.yaml with your service config
cat > apps/<your-team>/<environment>/<service-name>/values.yaml << EOF
image:
  repository: <your-ecr-repo>
  tag: latest

replicaCount: 2

service:
  port: 8080

ingress:
  enabled: true
  host: <service>.<env>.internal.tcs.com
EOF

# Commit and push
git add apps/
git commit -m "feat(gitops): onboard <service> for <team> in <environment>"
git push
```

ArgoCD will detect the new directory within 3 minutes (polling interval) and create the Application automatically.

## Sync Windows

Production syncs are gated by ArgoCD SyncWindows. Automated syncs in `prod` are allowed:
- Monday-Friday 08:00-18:00 UTC
- Manual override available via ArgoCD UI for urgent hotfixes

## Naming Convention

| Field | Pattern | Example |
|-------|---------|---------|
| Application name | `<service>-<team>-<env>` | `order-service-commerce-prod` |
| Namespace | `<team>-<env>` | `commerce-prod` |
| Slack notification channel | `<team>-deployments` | `commerce-deployments` |
