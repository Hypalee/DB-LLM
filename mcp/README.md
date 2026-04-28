# mcp/

Référentiel des MCP (Model Context Protocol) utilisés ou recommandés
pour mes projets. **Un fichier par service.**

## À lire avant

Voir `learning/02-mcp.md` pour comprendre ce qu'est MCP, les scopes
(user / project / local), et le pattern cross-repo retenu.

## Principe

- Mes MCP (Neon, Vercel, Resend) sont configurés en **scope user**
  dans mon profil Claude Code (`claude mcp add --scope user …`),
  donc disponibles automatiquement dans tous mes projets sans
  config par repo.
- Ce dossier `mcp/` **documente** ces MCP : capacités, conventions
  d'usage, pièges. Aucune config active ici.

Le scope project (via `.mcp.json` committé à la racine d'un repo) reste
une option valide en général — utile pour partager une config en équipe
ou pour un workflow mobile-first sans CLI. Voir `learning/02-mcp.md`
pour le détail des trois scopes.

## Fiches disponibles

| MCP | Service | Statut | Fiche |
|-----|---------|--------|-------|
| Neon | Postgres serverless | Officiel, stable | [`neon.md`](./neon.md) |
| Vercel | Hébergement Next.js | Officiel, beta | [`vercel.md`](./vercel.md) |
| Resend | Emails transactionnels | Officiel, stable | [`resend.md`](./resend.md) |

## Convention d'ajout d'un nouveau MCP

Quand j'ajoute un nouveau MCP :

1. Créer `mcp/<service>.md` en suivant le format des fiches
   existantes.
2. Ajouter la ligne dans le tableau ci-dessus.
3. Référencer dans `CLAUDE.md` global si le MCP a des conventions
   d'usage universelles (ex: "toujours créer une branche Neon avant
   de modifier un schéma").
4. Noter l'installation dans `memory/decisions.md` si le choix du MCP
   est structurant.
