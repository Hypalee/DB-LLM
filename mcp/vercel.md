# MCP — Vercel

## Service

Vercel : hébergement de mes apps Next.js (Brain et suivants).

## Statut

**Officiel** — maintenu par Vercel. Hosted à `mcp.vercel.com`.
Actuellement en **public beta**. Usage soumis aux conditions beta
et AI Product Terms de Vercel.

## Capacités

### Tools publics (sans auth)

- Chercher dans la doc Vercel, naviguer les guides.

### Tools authentifiés

- Lister projets et déploiements.
- Inspecter les logs de build.
- Inspecter les logs de runtime d'un déploiement.
- Déclencher un redéploiement.
- Gestion limitée du projet (selon ton rôle sur le projet Vercel).

## Authentification

OAuth sur ton compte Vercel.

## Setup

```bash
claude mcp add --scope user --transport http vercel https://mcp.vercel.com/sse
```

## Conventions d'usage

1. **Inspection logs avant intervention** : face à un problème de
   prod, toujours demander au MCP de remonter les logs du dernier
   déploiement avant de tenter un fix.
2. **Redéploy : OK, changements de config : prudence**. Un
   redéploiement qui a seulement besoin de rejouer un build est
   sans risque. Modifier les env vars ou les domaines via MCP est
   risqué — préférer le dashboard pour ces actions-là tant que
   l'outil est en beta.
3. **Vérifier post-déploiement** : un skill `/deploy-vercel` peut
   chainer "redéploie + suis les logs + vérifie 200 OK".

## Pièges

- **Beta** : comportement et liste d'outils susceptibles de changer.
  Si un outil disparaît ou évolue, ne pas paniquer, vérifier la doc.
- **Preview vs Production** : toujours confirmer sur quel
  environnement l'action va s'appliquer avant de trigger un deploy.
- **Cache de build** : si redéploiement donne des résultats bizarres,
  tenter "redeploy without cache" (option dans le dashboard, pas
  toujours exposée au MCP).

## Docs

- [Model Context Protocol - Vercel Docs](https://vercel.com/docs/mcp)
- [Use Vercel's MCP server](https://vercel.com/docs/agent-resources/vercel-mcp)
- [Annonce / FAQ MCP Vercel](https://vercel.com/blog/model-context-protocol-mcp-explained)
