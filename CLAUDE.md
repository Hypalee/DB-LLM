# CLAUDE.md — Profil de dev

> Ce fichier est mon **profil de dev** : qui je suis, ma stack, mes
> conventions, ma philosophie de travail. Il sert de contexte pour les
> sessions Claude Code dans **ce repo** (DB-LLM), qui est un labo
> d'apprentissage IA personnel — chapitres `learning/`, doc MCP,
> expérimentations sur Claude Code, hooks, agents.
>
> Ce repo n'est **plus importé** dans d'autres projets (cf. décision
> "2026-04-26 — Découplage" dans `memory/decisions.md`). Chaque projet
> de prod a son `CLAUDE.md` auto-portant.

## 1. Profil développeur

- **Localisation** : France (fuseau Europe/Paris)
- **Mode** : développeur solo, sans équipe
- **Stack principale** :
  - Frontend : Next.js 16 (App Router), React, Tailwind v4
  - Backend : Routes API Next.js, Server Actions
  - DB : Neon Postgres (serverless)
  - Auth : Better Auth (plugins selon projet)
  - IA : Anthropic SDK (Claude)
  - Hébergement : Vercel
  - DNS : Cloudflare
  - Paiement (à venir) : Stripe
- **Outils** : Claude Code CLI, GitHub, VS Code

## 2. Conventions code

### Langage
- **TypeScript strict obligatoire**. Pas de `any`, pas de `as any`, pas de
  `@ts-ignore`. Si le type est dur à exprimer, modéliser proprement (union,
  generic, `unknown` + narrowing).
- **Pas de workaround**. Si un hack semble nécessaire, creuser la cause
  racine. Préférer supprimer du code plutôt qu'en ajouter.
- **Commentaires uniquement pour le *pourquoi* non-évident** (contrainte
  cachée, bug contourné, invariant subtil). Jamais pour décrire ce que
  fait le code.
- **Nommage** : variables, fonctions, fichiers et identifiants en anglais.

### UI
- Textes affichés à l'utilisateur en **français**.
- Tailwind v4, classes utilitaires directement dans le JSX (pas de
  `@apply` sauf exception justifiée).
- Accessibilité : labels associés, focus visible, contrastes AA minimum.

### Git
- **Commits en français**, conventional commits :
  - `feat(scope): ...` nouvelle fonctionnalité
  - `fix(scope): ...` correction
  - `refactor(scope): ...` refacto sans changement fonctionnel
  - `chore(scope): ...` config, deps, outillage
  - `docs(scope): ...` documentation
- **Scope** = zone touchée (ex: `auth`, `notes`, `db`, `api`, `ui`).
- Un commit = une intention. Pas de commits fourre-tout.
- **Jamais `--no-verify`**, jamais `push --force` sur `main`.

### Architecture
- **Simplicité d'abord**. Pas d'abstraction prématurée : trois lignes
  dupliquées > un helper mal conçu.
- Pas de feature flag ni de shim de rétrocompat si on peut juste changer
  le code.
- Validation aux frontières seulement (input user, API externe). À
  l'intérieur du code, faire confiance aux types et aux garanties du
  framework.
- Un fichier, une responsabilité. Si un module dépasse ~300 lignes ou
  mélange plusieurs préoccupations, découper.

## 3. Philosophie de travail

- **Simple, propre, zéro workaround.**
- **Préférer supprimer plutôt qu'ajouter.** Code non utilisé = dette.
- **Fix the root cause, not the symptom.**
- **Ship small, ship often.** Pas de branches longues.
- **Claude est un pair**, pas un générateur. Je veux comprendre ce qui est
  écrit avant de le merger.

## 4. MCP configurés (scope user)

Les MCP ci-dessous sont configurés dans mon profil Claude Code et
disponibles **dans tous mes projets**. La config active vit au niveau
user, ce dossier `mcp/` contient uniquement la **documentation**
(capacités, conventions, pièges). Voir `learning/02-mcp.md` pour le
pattern complet.

| MCP | Service | Fiche |
|-----|---------|-------|
| Neon | Postgres serverless | `mcp/neon.md` |
| Vercel | Hébergement Next.js | `mcp/vercel.md` |
| Resend | Emails transactionnels | `mcp/resend.md` |

Règles universelles quand un MCP est utilisé :
- Lire la fiche correspondante avant d'exécuter une action non
  triviale.
- Respecter les conventions d'usage (jamais de SQL destructif sur
  branche Neon main, jamais de redeploy Vercel prod sans vérif logs,
  jamais d'envoi Resend de masse sans confirmation explicite).

## 5. Règles universelles pour Claude Code

Quand Claude Code travaille sur ce repo :

1. **Ne jamais pousser sur `main` directement.** Toujours branche + PR.
   - **Exception, ce repo (DB-LLM) uniquement** : merge direct sur `main`
     autorisé si je te le demande explicitement. C'est un labo
     d'apprentissage perso, pas un projet de prod. Cette exception
     **ne s'étend à aucun autre repo** : elle ne vaut que parce
     qu'elle est écrite ici, dans le `CLAUDE.md` de DB-LLM.
2. **Ne jamais committer de `.env`**, clés API, ou secrets. Si un secret
   est détecté dans le diff, arrêter et alerter.
3. **Avant un changement de schéma DB** (migration, colonne, contrainte),
   vérifier si d'autres tables/plugins (ex: Better Auth) ont des attentes
   sur ce schéma. Documenter la migration dans `memory/decisions.md`.
4. **Avant d'ajouter une dépendance**, vérifier qu'elle n'est pas déjà
   couverte par l'existant. Justifier l'ajout dans le commit.
5. **Tests UI** : si un changement touche l'interface, le tester dans un
   navigateur avant de déclarer la tâche terminée. Sinon le dire
   explicitement.
6. **Quand une décision architecturale est prise**, l'ajouter à
   `memory/decisions.md` avec la date et le raisonnement.
7. **Quand un piège est découvert** (bug subtil, comportement non
   documenté lié à Claude Code, à un MCP, à un pattern d'agent),
   l'ajouter à `memory/gotchas.md`.
8. **Quand tu m'expliques en détail un concept IA / Claude Code /
   agents** (définitions, patterns, architectures, tradeoffs), ou
   quand je te demande explicitement de prendre des notes, écrire un
   nouveau chapitre ou enrichir un chapitre existant dans `learning/`.
   Format : chapitres numérotés (`NN-titre.md`), TOC en tête,
   auto-portant (lisible à froid), pensé pour export PDF et partage.
   Voir `learning/README.md` pour la convention.

## 6. Note historique — pattern submodule abandonné

> **2026-04-26** — Ce repo a initialement été conçu pour être importé
> dans mes projets de prod (<projet>) via un submodule git + `@imports`
> dans le `CLAUDE.md` local. Ce pattern a été abandonné le 2026-04-26
> au profit d'un découplage strict : chaque projet de prod a son
> `CLAUDE.md` auto-portant, DB-LLM se recentre sur sa vocation de labo
> d'apprentissage IA personnel.
>
> La documentation du pattern est conservée à titre pédagogique :
> `INTEGRATION.md`, `WORKFLOW.md`, et les sections concernées des
> chapitres `learning/` (notamment `01-fondamentaux.md` §10,
> `02-mcp.md` §6, `04-orchestration-multi-agents.md` §4). Ces
> documents portent un encadré historique en tête.
>
> Décision détaillée : `memory/decisions.md` → "2026-04-26 —
> Découplage <projet> ↔ DB-LLM".
