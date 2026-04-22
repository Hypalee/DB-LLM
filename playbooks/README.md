# playbooks/

Procédures **step-by-step** pour des opérations complexes que je ne
veux pas réinventer à chaque fois. Un playbook = un script humain +
Claude : tu suis, tu valides, tu ne devines pas.

## Différence avec `skills/`

- **skill** = capacité réutilisable, appelée en cours de tâche
  ("déploie", "debug").
- **playbook** = opération complète du début à la fin, souvent longue,
  avec plusieurs points de validation ("lancer un nouveau projet").

## Playbooks disponibles

- [`new-project.md`](./new-project.md) — Lancer un nouveau projet
  (repo, stack, domaine, déploiement, intégration dans claude-config)
- [`db-migration.md`](./db-migration.md) — Faire une migration DB
  en sécurité (branche Neon → test → prod)
- [`new-service-integration.md`](./new-service-integration.md) —
  Intégrer un nouveau service tiers (ex: Stripe, Resend) proprement
