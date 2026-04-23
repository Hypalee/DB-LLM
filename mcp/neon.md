# MCP — Neon

## Service

Neon Postgres serverless. DB principale de mes projets (Brain et
suivants).

## Statut

**Officiel** — maintenu par Neon. Hosted à `mcp.neon.tech`.

## Capacités

- Lister projets, branches, databases.
- Créer / supprimer des branches (pour tester une migration sans
  toucher la prod).
- Exécuter des requêtes SQL.
- Décrire un schéma de table.
- Gérer la compute (suspended / active).

## Authentification

OAuth. Tu te connectes à ton compte Neon dans le navigateur, Claude
obtient un token scopé à tes projets.

## Setup (quand tu as un PC avec Claude Code CLI)

```bash
claude mcp add --scope user --transport http neon https://mcp.neon.tech/sse
```

Le scope `user` rend le MCP disponible dans **tous tes projets**,
pas seulement celui-ci.

## Conventions d'usage

1. **Jamais d'action destructive via MCP sur la branche `main` d'un
   projet Neon en prod**. Toujours passer par une branche de test.
2. **Migrations** : le MCP peut exécuter du SQL, mais pour les
   migrations versionnées, suivre `playbooks/db-migration.md` (écrire
   un fichier de migration, tester sur branche, merger, déployer).
3. **Pas utilisable en runtime par les apps**. Ce MCP est pour
   Claude Code / IDE, pas pour ton app Next.js en prod. L'app
   utilise `DATABASE_URL` / `DIRECT_URL` classiques.

## Pièges

- **Branches Neon ≠ branches git**. Une branche Neon est une copie
  de la base. Ne pas confondre.
- **Compute suspended** sur plan free : le premier call met 1-2s,
  c'est normal.
- **Production warning** : Neon précise que ce MCP est "for local
  development and IDE integrations only". Donc : outil de dev, pas
  de pipeline runtime.

## Docs

- [Neon MCP Server overview](https://neon.com/docs/ai/neon-mcp-server)
- [GitHub repo](https://github.com/neondatabase/mcp-server-neon)
- [Annonce blog](https://neon.com/blog/let-claude-manage-your-neon-databases-our-mcp-server-is-here)
