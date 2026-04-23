# mcp/

Référentiel des MCP (Model Context Protocol) utilisés ou recommandés
pour mes projets. **Un fichier par service.**

## À lire avant

Voir `learning/02-mcp.md` pour comprendre ce qu'est MCP, les scopes
(user / project / local), et le pattern cross-repo retenu.

## Principe

- Les MCP sont configurés en **scope user** (profil Claude Code
  global), donc disponibles dans tous les projets.
- Ce dossier `mcp/` **documente** les MCP configurés : quelles
  capacités, quelles conventions, quels pièges.
- Les commandes de setup sont listées dans chaque fiche — à exécuter
  une fois, la première fois que tu es sur un environnement où
  Claude Code CLI est installé.

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
