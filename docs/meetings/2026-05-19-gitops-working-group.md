# GitOps Working Group - Inaugural Meeting
**Date:** 2026-05-19
**Attendees:** Arjun Mehta, Rito Rama, Ahmed Jamil, Hortison (SRE), Alex Quincy, Jamie Plu, Lee Calcote
**Facilitator:** Arjun Mehta

## Agenda
1. ArgoCD bootstrap status
2. ApplicationSet design review
3. KEDA scaler rollout plan
4. Team onboarding timeline

## Discussion

### ArgoCD Bootstrap
Bootstrap PR merged. App-of-apps managing cert-manager and ingress-nginx. ApplicationSet generator active. First team app (platform-team dev environment) successfully deployed via the new structure.

### ApplicationSet Design
Reviewed and agreed: git directory generator with `apps/<team>/<env>/<service>/` structure. Helm values per environment. Rito to create the onboarding guide and add a `scripts/init-team.sh` helper.

### KEDA Scaler Rollout
KEDA ScaledObject templates merged. First deployment: SQS scaler for the notification service in dev. Results: scaling from 1 to 8 replicas in 90s on queue depth spike, scale-down in 5 minutes after cooldown. No issues.

Kafka scaler to be validated next sprint with the event streaming team.

### Team Onboarding Timeline
- Week of May 20: Platform team self-validates the GitOps flow end-to-end
- Week of May 26: First external team onboarded (commerce team)
- Week of June 2: All remaining teams migrated from manual deploys

## Decisions
1. ApplicationSet git directory pattern adopted as standard
2. KEDA SQS scaler validated, ready for teams
3. Onboarding schedule confirmed

## Action Items
| Owner | Action | Due |
|-------|--------|-----|
| Rito | Create team onboarding guide + init script | 2026-05-21 |
| Ahmed | Validate Kafka scaler with event streaming team | 2026-05-28 |
| Hortison | KEDA HTTP add-on evaluation in dev | 2026-05-28 |
| Arjun | Draft ArgoCD Rollouts AnalysisTemplate for tier-1 services | 2026-05-23 |
| Lee | Architecture review: DORA metrics pipeline design | 2026-05-26 |
