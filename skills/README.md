# skills/

Skills Claude Code réutilisables. Chaque fichier `.md` décrit une tâche
récurrente : **quand l'invoquer**, **quels inputs attendre**, **quelles
étapes suivre**, **quels pièges éviter**.

## Format

Chaque skill suit ce squelette :

```md
# <nom du skill>

## Quand l'utiliser
<déclencheurs clairs>

## Inputs attendus
<ce que l'utilisateur doit fournir>

## Procédure
1. ...
2. ...

## Pièges à éviter
- ...

## Sortie attendue
<ce que le skill produit>
```

## Skills disponibles

- [`deploy-vercel.md`](./deploy-vercel.md) — Déployer/redéployer un
  projet Next.js sur Vercel
- [`debug-neon.md`](./debug-neon.md) — Diagnostiquer un souci Neon
  Postgres (connexion, lenteurs, schéma)
- [`review-pr.md`](./review-pr.md) — Revue de PR selon mes standards
- [`setup-nextjs.md`](./setup-nextjs.md) — Bootstrap d'un nouveau projet
  Next.js 16 aligné avec ma stack
