# mcp/

Référentiel des MCP (Model Context Protocol) utilisés ou recommandés
pour mes projets. **Un fichier par service.**

## À lire avant

Voir `learning/02-mcp.md` pour comprendre ce qu'est MCP, les scopes
(user / project / local), et le pattern cross-repo retenu.

## Principe

- En pratique pour un workflow mobile-first (pas de CLI accessible) :
  les MCP sont déclarés dans un **`.mcp.json` à la racine du repo**
  (scope project, committé). Chaque repo embarque sa liste de MCP
  requis.
- Ce dossier `mcp/` **documente** les MCP utilisés : quelles
  capacités, quelles conventions, quels pièges.
- Sur desktop avec CLI, on peut aussi configurer en **scope user**
  (`claude mcp add --scope user …`), auquel cas le `.mcp.json` du
  repo devient redondant mais inoffensif.

Pour le détail scope project vs user, voir `learning/02-mcp.md`.

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
