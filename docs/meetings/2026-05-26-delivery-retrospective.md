# Delivery Team Retrospective - Sprint 4
**Date:** 2026-05-26
**Attendees:** Full delivery team (all GitOps WG members + Mia Cycle, Pontus Ringblom, Saraj Krishna Singh, Winkletinkle)
**Format:** Start/Stop/Continue + Action items

## Start
- **Automated image updates via ArgoCD Image Updater** - currently we're manually updating image tags in the GitOps repo. Image Updater will automate this after a successful CI build.
- **DORA metrics dashboard** - we have deployment frequency data from ArgoCD. Time to wire it into Grafana.
- **Progressive delivery for tier-1 services** - ArgoCD Rollouts is set up; no teams are using canary deploys yet. Start requiring it for tier-1.

## Stop
- **Manual hotfix deploys by committing directly to main** - every hotfix should go through a PR, even urgent ones. The CI takes 3 minutes. There's no excuse.
- **Skipping the pre-production checklist** - two services shipped to prod last sprint without liveness probes. This caused unnecessary downtime during node maintenance.

## Continue
- **ArgoCD ApplicationSet approach** - it's working well. First external team onboarded this week with zero friction.
- **KEDA for event-driven services** - SQS scaler is performing well. Clear cost savings in non-prod.
- **Weekly GitOps WG** - the cross-team coordination has been valuable. Keep it.

## Action Items
| Owner | Action | Due |
|-------|--------|-----|
| Ahmed | Set up ArgoCD Image Updater | 2026-06-02 |
| Lee | DORA metrics Grafana dashboard design | 2026-06-05 |
| Arjun | Enforce pre-prod checklist via Backstage tech-insights | 2026-06-05 |
| Hortison | Document progressive delivery requirement for tier-1 in blueprint | 2026-06-03 |
| Mia | Update golden path CI to fail on missing liveness probe | 2026-06-03 |
